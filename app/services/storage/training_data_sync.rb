# frozen_string_literal: true

module Storage
  class TrainingDataSync
    COPY_OPERATION_SUCCESS_CODE = 'success'

    attr_accessor :src_image_url

    def initialize(src_image_url)
      @src_image_url = src_image_url
    end

    def run
      return if image_url_blob_already_copied

      _copy_id, _copy_status = blob_service_client.copy_blob_from_uri(
        Rails.env,
        blob_destination_path,
        src_image_url
      )
    end

    def image_url_blob_already_copied
      response = blob_service_client.get_blob_properties(Rails.env, blob_destination_path)
      response.properties[:copy_status] == COPY_OPERATION_SUCCESS_CODE
    rescue Azure::Core::Http::HTTPError => _e
      # treat all errors as a failure and attempt to re-copy
      # we can refine this via the response status code
      # e.g. _e.status_code == 404 -> blob doesn't exist yet
      false
    end

    private

    def blob_service_client
      @blob_service_client ||= Azure::Storage::Blob::BlobService.create(
        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT_NAME'],
        storage_access_key: ENV['AZURE_STORAGE_ACCESS_KEY']
      )
    end

    def blob_destination_path
      @blob_destination_path ||= Zoobot.training_image_path(src_image_url)
    end
  end
end
