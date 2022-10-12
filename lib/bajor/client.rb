# frozen_string_literal: true

module Bajor
  class Client
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
      # store the submitted job id to check the job status later
      # via the bajor api, e.g. GET /jobs/:id
      submitted_job_id = bajor_client_response[:id]
    end
  end
end
