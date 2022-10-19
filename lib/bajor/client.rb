# frozen_string_literal: true

require 'httparty'

module Bajor
  class Client
    class Error < StandardError; end

    include HTTParty
    JSON_HEADERS = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }.freeze

    base_uri ENV.fetch('BAJOR_API_URL', 'https://bajor.zooniverse.org')

    basic_auth ENV.fetch('BAJOR_BASIC_AUTH_USERNAME', 'bajor'), ENV.fetch('BAJOR_BASIC_AUTH_PASSWORD', 'bajor')

    def create_training_job(manifest_path)
      bajor_response = self.class.post(
        '/training/jobs/',
        body: { manifest_path: manifest_path }.to_json,
        headers: JSON_HEADERS
      )

      # bajor returns 201 on successful submission
      raise_error(bajor_response['message']) if bajor_response.code != 201

      # return a bajor job tracking service URL
      bajor_training_job_tracking_url(bajor_response['id'])
    end

    def create_prediction_job(manifest_url)
      bajor_response = self.class.post(
        '/prediction/jobs/',
        body: { manifest_url: manifest_url }.to_json,
        headers: JSON_HEADERS
      )

      # bajor returns 201 on successful submission
      raise_error(bajor_response['message']) if bajor_response.code != 201

      # return a bajor job tracking service URL
      bajor_prediction_job_tracking_url(bajor_response['id'])
    end

    private

    def raise_error(msg)
      # most likely a 409 conflict error (limit of active jobs reached)
      # but could be a missing URL or service issue error (500) etc
      raise(Error, msg)
    end

    def bajor_training_job_tracking_url(submitted_job_id)
      "#{self.class.base_uri}/training/job/#{submitted_job_id}"
    end

    def bajor_prediction_job_tracking_url(submitted_job_id)
      "#{self.class.base_uri}/prediction/job/#{submitted_job_id}"
    end
  end
end
