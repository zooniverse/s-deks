# frozen_string_literal: true

require 'bajor/client'
require 'rails_helper'

RSpec.describe Bajor::Client do
  let(:bajor_client) { described_class.new }
  let(:bajor_host) { 'https://bajor-staging.zooniverse.org' }
  let(:request_headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Basic YmFqb3I6YmFqb3I=',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Ruby'
    }
  end

  describe 'create_training_job' do
    let(:request_url) { "#{bajor_host}/training/jobs/" }
    let(:catalogue_manifest_path) { 'training_catalogues/manifest_path.csv' }
    let(:request_body) do
      { manifest_path: catalogue_manifest_path }
    end
    let(:job_id) { '3ed68115-dc36-4f66-838c-a52869031676' }
    let(:bajor_response_body) do
      {
        'manifest_path' => catalogue_manifest_path,
        'id' => job_id,
        'status' => {
          'status' => 'submitted',
          'message' => 'Job submitted successfully'
        },
        'run_opts' => ''
      }
    end
    let(:request) do
      stub_request(:post, request_url)
        .with(
          body: request_body,
          headers: request_headers
        )
    end

    context 'with a success response' do
      before do
        request.to_return(status: 201, body: bajor_response_body.to_json, headers: { content_type: 'application/json' })
      end

      it 'correctly posts the manifest_path to bajor' do
        bajor_client.create_training_job(catalogue_manifest_path)
        expect(
          a_request(:post, request_url).with(body: request_body, headers: request_headers)
        ).to have_been_made.once
      end

      it 'returns the submitted job id as a batch job service url' do
        result = bajor_client.create_training_job(catalogue_manifest_path)
        expect(result).to eq("#{bajor_host}/training/job/#{job_id}")
      end
    end

    context 'with a failed repsonse' do
      let(:error_message) do
        'Active Jobs are running in the batch system - please wait till they are fininshed processing.'
      end
      let(:error_response) do
        {
          'state' => 'error',
          'message' => error_message
        }
      end

      before do
        request.to_return(status: 409, body: error_response.to_json, headers: { content_type: 'application/json' })
      end

      it 'raises an error' do
        expect { bajor_client.create_training_job(catalogue_manifest_path) }.to raise_error(Bajor::Client::Error, error_message)
      end
    end
  end

  describe 'create_prediction_job' do
    let(:request_url) { "#{bajor_host}/prediction/jobs/" }
    let(:manifest_url) { 'https://manifest-host.zooniverse.org/manifest.csv' }
    let(:request_body) do
      { manifest_url: manifest_url }
    end
    let(:job_id) { '3ed68115-dc36-4f66-838c-a52869031c9c' }
    let(:bajor_response_body) do
      {
        'manifest_url' => manifest_url,
        'id' => job_id,
        'status' => {
          'status' => 'submitted',
          'message' => 'Job submitted successfully'
        },
        'run_opts' => ''
      }
    end
    let(:request) do
      stub_request(:post, request_url)
        .with(
          body: request_body,
          headers: request_headers
        )
    end

    context 'with a success response' do
      before do
        request.to_return(status: 201, body: bajor_response_body.to_json, headers: { content_type: 'application/json' })
      end

      it 'correctly posts the prediction job to bajor' do
        bajor_client.create_prediction_job(manifest_url)
        expect(
          a_request(:post, request_url).with(body: request_body, headers: request_headers)
        ).to have_been_made.once
      end

      it 'returns the submitted job id as a batch job service url' do
        result = bajor_client.create_prediction_job(manifest_url)
        expect(result).to eq("#{bajor_host}/prediction/job/#{job_id}")
      end
    end

    context 'with a failed repsonse' do
      let(:error_message) do
        'Active Jobs are running in the batch system - please wait till they are fininshed processing.'
      end
      let(:error_response) do
        {
          'state' => 'error',
          'message' => error_message
        }
      end

      before do
        request.to_return(status: 409, body: error_response.to_json, headers: { content_type: 'application/json' })
      end

      it 'raises an error' do
        expect { bajor_client.create_prediction_job(manifest_url) }.to raise_error(Bajor::Client::Error, error_message)
      end
    end
  end
end
