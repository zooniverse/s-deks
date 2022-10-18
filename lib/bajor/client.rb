# frozen_string_literal: true

module Bajor
  class Client
    class Error < StandardError; end

    include HTTParty
    JSON_HEADERS = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }.freeze

    base_uri ENV.fetch('BAJOR_API_URL', 'https://bajor.zooniverse.org')

    basic_auth ENV.fetch('BAJOR_BASIC_AUTH_USERNAME', 'bajor'), ENV.fetch('BAJOR_BASIC_AUTH_PASSWORD', 'bajor')

    def train(manifest_path)
      self.class.post(
        '/training/jobs/',
        body: { manifest_path: manifest_path }.to_json,
        headers: JSON_HEADERS
      )
    end

    def create_prediction_job(manifest_url)
      bajor_response = self.class.post(
        '/prediction/jobs/',
        body: { manifest_url: manifest_url }.to_json,
        headers: JSON_HEADERS
      )
      # handle known error codes from bajor
      if bajor_response.code != 201
        # most likely a 409 conflict error (limit of active jobs reached)
        # but could be a missing URL or service issue error (500) etc
        raise(Error, bajor_response['message'])
      end

      # return a bajor job tracking service URL
      submitted_job_id = bajor_response['id']
      "#{self.class.base_uri}/prediction/job/#{submitted_job_id}"
    end
  end
end
