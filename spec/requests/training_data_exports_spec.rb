# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TrainingDataExports', type: :request do
  fixtures :contexts

  let(:context) { Context.first }
  let(:request_headers) do
    # long term look at switching this to panoptes JWT auth via gem 'panoptes-client'
    json_headers_with_basic_auth(
      Rails.application.config.api_basic_auth_username,
      Rails.application.config.api_basic_auth_password
    )
  end

  describe 'POST /training_data_exports' do
    let(:training_data_export_json_payload) do
      { training_data_export: { workflow_id: context.workflow_id } }.to_json
    end
    let(:create_request) do
      post '/training_data_exports', params: training_data_export_json_payload, headers: request_headers
    end

    it 'returns the created response' do
      create_request
      expect(response).to have_http_status(:created)
    end

    it 'serializes the created training_data_export in the response body as json' do
      create_request
      expected_attributes = %w[id workflow_id state storage_path created_at updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
    end

    it 'runs the export worker' do
      allow(TrainingDataExporterJob).to receive(:perform_async)
      create_request
      expect(TrainingDataExporterJob).to have_received(:perform_async).with(Integer)
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

  describe 'GET /training_data_exports/:id' do
    let(:get_request) do
      get "/training_data_exports/#{training_data_export.id}", headers: request_headers
    end
    let(:storage_path) { "/test/training_catalogue/workflow-111-#{Time.now.iso8601}.csv" }
    let(:training_data_export) do
      TrainingDataExport.create(workflow_id: context.workflow_id, storage_path: storage_path)
    end

    before do
      training_data_export
    end

    it 'returns the ok response' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it 'serailizes the created training_data_export in the response body as json' do
      get_request
      expected_attributes = {
        'id' => training_data_export.id,
        'workflow_id' => training_data_export.workflow_id,
        'state' => 'started',
        'storage_path' => training_data_export.storage_path
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

  describe 'GET /training_data_exports/' do
    let(:get_request) do
      get '/training_data_exports', headers: request_headers
    end

    before do
      TrainingDataExport.create(workflow_id: context.workflow_id, storage_path: 'path_1')
      TrainingDataExport.create(workflow_id: context.workflow_id, storage_path: 'path_2')
    end

    it 'returns the ok response' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it 'returns both training data export records' do
      get_request
      expect(json_parsed_response_body.length).to eq(2)
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
end
