# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserReductions', type: :request do
  describe 'POST /user_reductions' do
    let(:user_reduction_json_payload) do
      {
        user_reduction: {
          id: 4,
          reducible: {
            id: 4,
            type: 'Workflow'
          },
          data: {
            '0' => 3,
            '1' => 9,
            '2' => 0
          },
          subject: {
            id: 4,
            metadata: {},
            created_at: '2021-08-06T11:08:53.918Z',
            updated_at: '2021-08-06T11:08:53.918Z'
          },
          created_at: '2021-08-06T11:08:54.000Z',
          updated_at: '2021-08-06T11:08:54.000Z'
        }
      }.to_json
    end
    let(:request_headers) do
      json_headers_with_basic_auth(ReductionBasicAuth.username, ReductionBasicAuth.password)
    end
    let(:create_request) { post '/user_reductions', params: user_reduction_json_payload, headers: request_headers }

    it 'returns the created response' do
      create_request
      expect(response).to have_http_status(:created)
    end

    it 'serailizes the created user_reduction in the response body as json' do
      create_request
      expected_attributes = %w[id subject_id workflow_id labels raw_payload created_at updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
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
