# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TrainingDataExports', type: :request do
  describe 'POST /training_data_exports' do
    fixtures :contexts

    let(:context) { Context.first }
    let(:training_data_export_json_payload) do
      { training_data_export: { workflow_id: context.workflow_id } }.to_json
    end
    let(:request_headers) do
      # long term look at switching this to panoptes JWT auth via gem 'panoptes-client'
      json_headers_with_basic_auth(
        Rails.application.config.api_basic_auth_username,
        Rails.application.config.api_basic_auth_password
      )
    end
    let(:create_request) do
      post '/training_data_exports', params: training_data_export_json_payload, headers: request_headers
    end

    before do
      reduction_subject = Subject.create(zooniverse_subject_id: 999, context_id: context.id)
      UserReduction.create(
        {
          subject_id: reduction_subject.id,
          workflow_id: context.workflow_id,
          labels: {
            'smooth-or-featured_smooth' => 3,
            'smooth-or-featured_featured-or-disk' => 9,
            'smooth-or-featured_artifact' => 0
          },
          unique_id: '8000_231121_468',
          raw_payload: {}
        }
      )
    end

    it 'returns the created response' do
      create_request
      expect(response).to have_http_status(:created)
    end

    it 'serailizes the created training_data_export in the response body as json' do
      create_request
      expected_attributes = %w[id workflow_id state storage_path created_at updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
    end

    it 'runs the export service instace' do
      training_data_export_service = instance_double(Export::TrainingData)
      allow(training_data_export_service).to receive(:run)
      allow(Export::TrainingData).to receive(:new).with(TrainingDataExport).and_return(training_data_export_service)
      create_request
      expect(training_data_export_service).to have_received(:run)
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
