# frozen_string_literal: true

module RequestHelpers
  def json_headers
    { 'CONTENT_TYPE' => 'application/json' }
  end

  def json_headers_with_basic_auth(username, password)
    basic_auth_creds = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    json_headers.merge('HTTP_AUTHORIZATION' => basic_auth_creds)
  end

  def json_parsed_response_body
    JSON.parse(response.body)
  end
end
