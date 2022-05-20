# frozen_string_literal: true

module Storage
  class TrainingDataSync
    COPY_OPERATION_OK_CODES = %w[success pending].freeze
    PROD_CONTAINER_URL_PREFIX = 'https://panoptesuploads.blob.core.windows.net/public'
    STAGING_CONTAINER_URL_PREFIX = 'https://panoptesuploadsstaging.blob.core.windows.net/public'

    attr_accessor :src_image_url

    def initialize(src_image_url)
      @src_image_url = src_image_url
    end

    def run
      return if image_url_blob_already_copied_or_pending

      _copy_id, _copy_status = blob_service_client.copy_blob_from_uri(
        Rails.env,
        blob_destination_path,
        src_blob_uri_from_src_url
      )
    end

    def image_url_blob_already_copied_or_pending
      response = blob_service_client.get_blob_properties(Rails.env, blob_destination_path)
      # skip requesting a copy operation if the blob is already copied or pending / scheduled for copy
      # failure / aborts will return false and schedule a new copy
      # https://docs.microsoft.com/en-us/rest/api/storageservices/Copy-Blob?redirectedfrom=MSDN#working-with-a-pending-copy-operation-version-2012-02-12-and-newer
      COPY_OPERATION_OK_CODES.include?(response.properties[:copy_status])
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

    # convert the public / CDN url to a blob storage conatiner URL
    # in testing the public CDN url works some of the time so let's use the
    # storage / container URIs to make sure the copies work
    def src_blob_uri_from_src_url
      parsed_uri = URI.parse(src_image_url)
      if Rails.env.production?
        "#{PROD_CONTAINER_URL_PREFIX}#{parsed_uri.path}"
      else
        "#{STAGING_CONTAINER_URL_PREFIX}#{parsed_uri.path}"
      end
    end
  end
end
