# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PredictionJobs', type: :request do
  let(:request_headers) do
    json_headers_with_basic_auth(
      Rails.application.config.api_basic_auth_username,
      Rails.application.config.api_basic_auth_password
    )
  end
  let(:manifest_url) { 'https://manifest-host.zooniverse.org/manifest.csv' }
  let(:prediction_job) do
    PredictionJob.create(manifest_url: manifest_url, state: :pending)
  end

  describe 'GET /prediction_jobs/:id' do
    let(:get_request) do
      get "/prediction_jobs/#{prediction_job.id}", headers: request_headers
    end

    it 'returns the ok response' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it 'serializes the correct resource response body' do
      get_request
      expected_attributes = {
        'id' => prediction_job.id,
        'state' => prediction_job.state,
        'manifest_url' => prediction_job.manifest_url,
        'service_job_url' => '',
        'message' => ''
      }
      expect(json_parsed_response_body).to include(expected_attributes)
    end

    context 'with invalid authentication credentials' do
      let(:request_headers) do
        json_headers_with_basic_auth('unknown', 'credentials')
      end

      it 'returns unauthorized response' do
        get_request
        expect(response.status).to eq(401)
      end
    end

    context 'without an authorization header' do
      let(:request_headers) { json_headers }

      it 'returns unauthorized response' do
        get_request
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'GET /prediction_jobs/' do
    before do
      prediction_job
    end

    it 'returns the ok response' do
      get '/prediction_jobs/', headers: request_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns the prediciton job records' do
      get '/prediction_jobs/', headers: request_headers
      expect(json_parsed_response_body.length).to eq(1)
    end
  end

  describe 'POST /prediction_jobs/' do
    let(:unwrapped_payload) do
      {
        manifest_url: manifest_url
      }
    end
    let(:json_payload) do
      { prediction_job: unwrapped_payload }.to_json
    end
    let(:create_request) { post '/prediction_jobs', params: json_payload, headers: request_headers }
    let(:prediciton_job_result) { PredictionJob.new }

    before do
      create_job_service_double = instance_double(Batch::Prediction::CreateJob, run: prediciton_job_result)
      allow(Batch::Prediction::CreateJob).to receive(:new).and_return(create_job_service_double)
    end

    it 'creates a PredictionJob resource' do
      expect { create_request }.to change(PredictionJob, :count).by(1)
    end

    it 'returns the created response' do
      create_request
      expect(response).to have_http_status(:created)
    end

    it 'serailizes the created prediction job in the response body as json' do
      create_request
      expected_attributes = %w[created_at id manifest_url message service_job_url state updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
    end

    context 'with unrwapped params' do
      let(:json_payload) do
        unwrapped_payload.to_json
      end

      it 'returns the created response' do
        create_request
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid authentication credentials' do
      let(:request_headers) do
        json_headers_with_basic_auth('unknown', 'credentials')
      end

      it 'returns unauthorized response' do
        create_request
        expect(response.status).to eq(401)
      end
    end

    context 'without an authorization header' do
      let(:request_headers) { json_headers }

      it 'returns unauthorized response' do
        create_request
        expect(response.status).to eq(401)
      end
    end
  end
end
