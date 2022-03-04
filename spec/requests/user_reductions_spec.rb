# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserReductions', type: :request do
  describe 'POST /user_reductions' do
    before do
      post '/user_reductions', params: user_reduction_json_payload, headers: json_headers
    end

    it 'returns the created response' do
      expect(response).to have_http_status(:created)
    end

    it 'serailizes the created user_reduction in the response body as json' do
      expected_attributes = %w[id subject_id workflow_id labels raw_payload created_at updated_at]
      expect(json_parsed_response_body.keys).to match_array(expected_attributes)
    end
  end
end
