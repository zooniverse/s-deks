# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserReductions', type: :request do
  fixtures :contexts

  let(:context) { Context.first }
  let(:non_create_request_headers) do
    json_headers_with_basic_auth(
      Rails.application.config.api_basic_auth_username,
      Rails.application.config.api_basic_auth_password
    )
  end
  let(:create_request_headers) do
    json_headers_with_basic_auth(
      Rails.application.config.user_reduction_basic_auth_username,
      Rails.application.config.user_reduction_basic_auth_password
    )
  end
  let(:subject_instance) do
    Subject.create(zooniverse_subject_id: 999, context_id: context.id)
  end
  let(:user_reduction) do
    UserReduction.create(
      {
        zooniverse_subject_id: subject_instance.zooniverse_subject_id,
        subject_id: subject_instance.id,
        workflow_id: context.workflow_id,
        labels: {},
        unique_id: 'very_unique_id',
      }
    )
  end

  before do
    subject_instance
  end

  describe 'GET /user_reductions/:id' do
    let(:get_request) do
      get "/user_reductions/#{user_reduction.id}", headers: non_create_request_headers
    end

    it 'returns the ok response' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it 'serializes the json subject data in the response body' do
      get_request
      expected_attributes = {
        'id' => user_reduction.id,
        'zooniverse_subject_id' => user_reduction.zooniverse_subject_id,
        'labels' => user_reduction.labels,
        'unique_id' => user_reduction.unique_id
      }
      expect(json_parsed_response_body).to include(expected_attributes)
    end

    it 'serializes the linked subject json data in the response body' do
      get_request
      expect(json_parsed_response_body['subject']).not_to be_empty
    end

    context 'with invalid authentication credentials' do
      let(:non_create_request_headers) do
        json_headers_with_basic_auth('unknown', 'credentials')
      end

      it 'returns unauthorized response' do
        get_request
        expect(response.status).to eq(401)
      end
    end

    context 'without an authorization header' do
      let(:non_create_request_headers) { json_headers }

      it 'returns unauthorized response' do
        get_request
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'GET /user_reductions/' do
    before do
      user_reduction
    end

    it 'returns the ok response' do
      get '/user_reductions/', headers: non_create_request_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns both subject records' do
      get '/user_reductions/', headers: non_create_request_headers
      expect(json_parsed_response_body.length).to eq(1)
    end

    it 'filters via the ?zooniverse_subject_id param' do
      other_user_reduction = UserReduction.create(
        { zooniverse_subject_id: 1001, subject_id: -1, workflow_id: context.workflow_id, unique_id: 'more-unique' }
      )
      get "/user_reductions/?zooniverse_subject_id=#{other_user_reduction.zooniverse_subject_id}", headers: non_create_request_headers
      expect(json_parsed_response_body.length).to eq(1)
    end
  end

  describe 'POST /user_reductions' do
    let(:user_reduction_json_payload) do
      {
        user_reduction: {
          id: 4,
          reducible: {
            id: context.workflow_id,
            type: 'Workflow'
          },
          data: {
            '0' => 3,
            '1' => 9,
            '2' => 0
          },
          subject: {
            id: 999,
            metadata: { '#name' => '8000_231121_468' },
            created_at: '2021-08-06T11:08:53.918Z',
            updated_at: '2021-08-06T11:08:53.918Z'
          },
          created_at: '2021-08-06T11:08:54.000Z',
          updated_at: '2021-08-06T11:08:54.000Z'
        }
      }.to_json
    end
    let(:create_request) { post '/user_reductions', params: user_reduction_json_payload, headers: create_request_headers }

    it 'returns the created response' do
      create_request
      expect(response).to have_http_status(:created)
    end

    it 'serailizes the created user_reduction in the response body as json' do
      create_request
      expected_attributes = %w[id zooniverse_subject_id subject_id workflow_id labels raw_payload unique_id created_at updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
    end

    context 'with unrwapped params' do
      let(:user_reduction_json_payload) do
        {
          id: 4,
          reducible: {
            id: context.workflow_id,
            type: 'Workflow'
          },
          data: {
            '0' => 3,
            '1' => 9,
            '2' => 0
          },
          subject: {
            id: 999,
            metadata: { '#name' => '8000_231121_468' },
            created_at: '2021-08-06T11:08:53.918Z',
            updated_at: '2021-08-06T11:08:53.918Z'
          },
          created_at: '2021-08-06T11:08:54.000Z',
          updated_at: '2021-08-06T11:08:54.000Z'
        }.to_json
      end

      it 'returns the created response' do
        create_request
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid authentication credentials' do
      let(:create_request_headers) do
        json_headers_with_basic_auth('unknown', 'credentials')
      end

      it 'returns unauthorized response' do
        create_request
        expect(response.status).to eq(401)
      end
    end

    context 'without an authorization header' do
      let(:create_request_headers) { json_headers }

      it 'returns unauthorized response' do
        create_request
        expect(response.status).to eq(401)
      end
    end
  end
end
