# frozen_string_literal: true

require 'bajor/client'
require 'rails_helper'

RSpec.describe Bajor::Client do
  let(:bajor_client) { described_class.new }
  let(:catalogue_manifest_path) { 'training_catalogues/manifest_path.csv' }
  let(:bajor_host) { 'https://bajor.zooniverse.org'}
  let(:request_url) { "#{bajor_host}/jobs/" }
  let(:request_headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Basic YmFqb3I6YmFqb3I=',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Ruby'
    }
  end
  let(:request_body) {
    { manifest_path: catalogue_manifest_path }
  }

  describe 'train' do
    before do
      stub_request(:post, request_url)
        .with(
          body: request_body,
          headers: request_headers
        )
        .to_return(status: 201, body: '', headers: {content_type: 'application/json'})
    end

    let(:train_payload) do
      { body: { manifest_path: catalogue_manifest_path } }
    end

    it 'correctly posts the manifest_path to bajor' do
      bajor_client.train(catalogue_manifest_path)
      expect(
        a_request(:post, request_url).with(body: request_body, headers: request_headers)
      ).to have_been_made.once
    end
  end
end

