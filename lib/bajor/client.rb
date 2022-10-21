# frozen_string_literal: true

require 'httparty'

module Bajor
  class Client
    class Error < StandardError; end
    class PredictionJobTaskError < StandardError; end

    include HTTParty
    JSON_HEADERS = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }.freeze

    base_uri ENV.fetch('BAJOR_API_URL', 'https://bajor-staging.zooniverse.org')

    basic_auth ENV.fetch('BAJOR_BASIC_AUTH_USERNAME', 'bajor'), ENV.fetch('BAJOR_BASIC_AUTH_PASSWORD', 'bajor')

    BAJOR_PREDICTION_BLOB_STORE_HOST_CONTAINER_URL = 'https://kadeactivelearning.blob.core.windows.net/predictions'

    def create_training_job(manifest_path)
      bajor_response = self.class.post(
        '/training/jobs/',
        body: { manifest_path: manifest_path }.to_json,
        headers: JSON_HEADERS
      )

      # bajor returns 201 on successful submission
      raise_error(bajor_response) if bajor_response.code != 201

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
      raise_error(bajor_response) if bajor_response.code != 201

      # return a bajor job tracking service URL
      bajor_prediction_job_tracking_url(bajor_response['id'])
    end

    def prediction_job_results(job_id)
      bajor_response = self.class.get("/prediction/job/#{job_id}", headers: JSON_HEADERS)

      # bajor returns 200 on successful submission
      # anything else here will raise for notification at the callsite
      raise_error(bajor_response) if bajor_response.code != 200

      # loop over the task responses to collect the task results
      all_tasks_results = bajor_response['tasks'].map do |task|
        task.dig('execution_info', 'result')
      end

      if all_tasks_results.all?('success') # all tasks done and all good
        job_results_env_setting = bajor_response['common_environment_settings'].find do |env_setting|
          env_setting['name'] == 'PREDICTIONS_JOB_RESULTS_DIR'
        end
        # construct the prediction job results url
        # TODO: this will most likely change format but will do for now
        job_results_path_suffix = job_results_env_setting['value']
        "#{BAJOR_PREDICTION_BLOB_STORE_HOST_CONTAINER_URL}/#{job_results_path_suffix}/predictions.csv"
      elsif all_tasks_results.any?('failure') # one of the tasks failed :(
        message = "One or more prediction job tasks failed - see job log details from: #{self.class.base_uri}/prediction/job/#{job_id}"
        raise(PredictionJobTaskError, message)
      elsif all_tasks_results.any?(&:nil?) # tasks are still running
        nil
      end
    end

    private

    def raise_error(bajor_response)
      # bajor may return a json object with message body
      msg = bajor_response['message']
      # failing that let's try and craft a decent error message from the httparty response error
      msg ||= "Failed with response code: #{bajor_response.response.code} - #{bajor_response.response.message}"

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
