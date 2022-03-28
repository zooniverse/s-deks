# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subjects', type: :request do
  fixtures :contexts

  let(:context) { Context.first }
  let(:request_headers) do
    # long term look at switching this to panoptes JWT auth via gem 'panoptes-client'
    json_headers_with_basic_auth(
      Rails.application.config.api_basic_auth_username,
      Rails.application.config.api_basic_auth_password
    )
  end
  let(:zooniverse_subject_id) { 999 }
  let(:locations) do
    [{ 'image/jpeg' => 'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }]
  end
  let(:metadata) { { 'name' => '#uniq-name!' } }
  let(:subject_instance) do
    Subject.create({ zooniverse_subject_id: zooniverse_subject_id, context_id: context.id, metadata: metadata, locations: locations })
  end

  before do
    subject_instance
  end

  describe 'GET /subjects/' do
    before do
      Subject.create({ zooniverse_subject_id: 1000, context_id: context.id })
    end

    it 'returns the ok response' do
      get '/subjects/', headers: request_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns both subject records' do
      get '/subjects/', headers: request_headers
      expect(json_parsed_response_body.length).to eq(2)
    end

    it 'filters via the ?zooniverse_subject_id param' do
      get "/subjects/?zooniverse_subject_id=#{zooniverse_subject_id}", headers: request_headers
      expect(json_parsed_response_body.length).to eq(1)
      expect(json_parsed_response_body.first['zooniverse_subject_id']).to eq(zooniverse_subject_id)
    end
  end

  describe 'GET /subjects/:id' do
    let(:get_request) do
      get "/subjects/#{subject_instance.id}", headers: request_headers
    end

    it 'returns the ok response' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it 'serailizes the json subject data in the response body' do
      get_request
      expected_attributes = {
        'id' => subject_instance.id,
        'zooniverse_subject_id' => zooniverse_subject_id,
        'metadata' => metadata,
        'locations' => locations
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
end
