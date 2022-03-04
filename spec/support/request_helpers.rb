# frozen_string_literal: true

module RequestHelpers
  def json_headers
    { 'CONTENT_TYPE' => 'application/json' }
  end

  def user_reduction_json_payload
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

  def json_parsed_response_body
    JSON.parse(response.body)
  end
end
