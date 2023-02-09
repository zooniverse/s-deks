# frozen_string_literal: true

require 'panoptes/api'
require 'json'

module Batch
  module Prediction
    class ExportManifest
      attr_accessor :subject_set_id, :panoptes_client, :manifest_data, :subject_set, :project_id, :temp_file, :subject_set_subject_ids

      def initialize(subject_set_id, panoptes_client = Panoptes::Api.client)
        @subject_set_id = subject_set_id
        @panoptes_client = panoptes_client
        @manifest_data = []
        @subject_set_subject_ids = []
        @temp_file = Tempfile.new("prediction_manifest_subject_set#{subject_set_id}.csv")
      end

      def run
        @subject_set = panoptes_client.subject_set(subject_set_id)
        @project_id = subject_set.dig('links', 'project')
        # NOTE: the following use the async faraday adapter
        # to collect data async and speed up the manifest creation
        # collect all the subject ids in the subject set
        fetch_subject_set_subject_ids
        # enumerate the subjects and create the manifest data
        create_manifest_data

        # write the manifest data to a temp file
        write_manifest_data_to_temp_file

        # upload the manifest to blob storage
        upload_manifest_data_to_blob_storage
      ensure
        # cleanup the temp file
        temp_file.close
        temp_file.unlink
      end

      def fetch_subject_set_subject_ids(slices=4)
        return if subject_set_id.nil?

        query = { subject_set_id: subject_set_id }
        # this is a hack to get around the fact that the panoptes client
        # doesn't support the `set_member_subjects` types
        # using the SetMemberSubject Resource allows us to quickly
        # collect the subject ids linked to the set
        first_page = panoptes_client.panoptes.get('/set_member_subjects', query)
        first_page['set_member_subjects'].each do |set_member_subject|
          subject_set_subject_ids << set_member_subject['links']['subject']
        end

        page_count = first_page.dig('meta', 'set_member_subjects', 'page_count')
        return if page_count == 1

        # find the remaining pages of SetMemeberSubjects data asynchronously
        (2..page_count).each_slice(slices) do |page_nums|
          Async do
            page_nums.each do |page_num|
              page_query = { subject_set_id: subject_set_id, page: page_num }
              page = panoptes_client.panoptes.get('/set_member_subjects', page_query)
              page['set_member_subjects'].each do |set_member_subject|
                subject_set_subject_ids << set_member_subject['links']['subject']
              end
            end
          end
        end
      end

      def create_manifest_data(slices=4)
        subject_set_subject_ids.each_slice(slices) do |batch_of_subject_ids|
          subject_responses = []
          # fetch the subjects asynchronously, https://github.com/socketry/async-http-faraday
          Async do
            batch_of_subject_ids.each do |subject_id|
              subject_responses << panoptes_client.subject(subject_id)
            end
          end
          subject_responses.each do |subject|
            # Create a data row for each image URL in the Subject
            # this will duplicate the subject information for each image URL
            subject['locations'].each_with_index do |location, frame_id|
              manifest_data << [
                location.values[0], # image_url
                # The subject's JSON information is stored as a string,
                # Yes, really - this is the format that hamlet sets up.
                JSON.dump(
                  {
                    project_id: project_id,
                    subject_set_id: subject_set_id.to_s,
                    subject_id: subject['id'],
                    frame_id: frame_id.to_s
                  }
                )
              ]
            end
          end
        end
      end

      def write_manifest_data_to_temp_file
        temp_file.write(manifest_data.to_json)
        # rewind the file so it can be read when uploading to storage
        temp_file.rewind
      end

      def upload_manifest_data_to_blob_storage
        # configure the blob storage data and paths
        catalogue_prefix = ENV.fetch('PREDICTIONS_CATALOGUE_PREFIX', "catalogues/#{Rails.env}")
        storage_key = "/#{catalogue_prefix}/subject-set-#{subject_set_id}-#{Time.now.iso8601}.json"
        storage_filename = File.basename(storage_key)
        service_name = "#{Rails.env}-predictions" # see config/storage.yml

        # upload the prediction manifest to blob storage directly
        ActiveStorage::Blob.create_and_upload!(
          key: storage_key,
          io: temp_file,
          filename: storage_filename,
          service_name: service_name
        )
      end
    end
  end
end
