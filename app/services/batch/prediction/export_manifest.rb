# frozen_string_literal: true

require 'panoptes/api'
require 'json'

module Batch
  module Prediction
    class ExportManifest
      attr_accessor :subject_set_id, :panoptes_client, :manifest_data, :subject_set, :project_id, :temp_file

      def initialize(subject_set_id, panoptes_client = Panoptes::Api.client)
        @subject_set_id = subject_set_id
        @panoptes_client = panoptes_client
        @manifest_data = []
        @temp_file = Tempfile.new("prediction_manifest_subject_set#{subject_set_id}.csv")
      end

      def run
        @subject_set = panoptes_client.subject_set(subject_set_id)
        @project_id = subject_set.dig('links', 'project')
        create_manifest_data

        # write the manifest data to a file
        # TODO: this should be a temp file

        begin
          temp_file.write(manifest_data.to_json)
          # TODO: create a new PredictionDataExport model
          # really a place holder for these files

          # prediction_data_export.file.attach(
          #     key: training_data_export.storage_path_key,
          #     io: csv_export_file,
          #     filename: training_data_export.storage_path_file_name
          #   )
        ensure
          temp_file.close
          temp_file.unlink   # deletes the temp file
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

      def subject_set_subject_ids
        return [] if subject_set_id.nil?

        query = { subject_set_id: subject_set_id }
        subject_ids = []
        # TODO: this is a hack to get around the fact that the panoptes client
        # doesn't support the `set_member_subjects` types
        # but it allows us to quickly collect the subject ids as we page through them
        panoptes_client.panoptes.paginate('/set_member_subjects', query) do |page, _last_page_response|
          page['set_member_subjects'].map do |set_member_subject|
            subject_ids << set_member_subject['links']['subject']
          end
        end

        subject_ids
      end
    end
  end
end
