# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveSubjectFromSubjectSetJob, type: :job do
  describe 'perform' do
    let(:subject_ids) { [1, 2] }
    let(:subject_set_id) { 2 }
    let(:job) { described_class.new }
    let(:panoptes_client_double) { instance_double(Panoptes::Client) }
    # the following is an internal api client implementation
    # longer term it should be moved to a method on the client for reuse in other systems
    let(:panoptes_endpoint_double) { instance_double(Panoptes::Endpoints::JsonApiEndpoint) }

    before do
      allow(ENV).to receive(:fetch).with('PANOPTES_OAUTH_CLIENT_ID').and_return('fake-client-id')
      allow(ENV).to receive(:fetch).with('PANOPTES_OAUTH_CLIENT_SECRET').and_return('fake-client-sekreto')
      allow(panoptes_endpoint_double).to receive(:delete)
      allow(panoptes_client_double).to receive(:panoptes).and_return(panoptes_endpoint_double)
      allow(Panoptes::Client).to receive(:new).and_return(panoptes_client_double)
    end

    it 'calls the api client to remove the subject to the subject set' do
      job.perform(subject_ids, subject_set_id)
      expect(panoptes_endpoint_double).to have_received(:delete).with("/subject_sets/#{subject_set_id}/links/subjects/#{subject_ids.join(',')}")
    end

    context 'when the server has an error' do
      let(:error_msg) { '{"errors"=>[{"message"=>"Attempted to update a stale object: SubjectSet."}]}' }

      before do
        # https://github.com/zooniverse/panoptes-client.rb/blob/bf0cffdf87b96bc97ed1924a09bb924d7c80d79d/lib/panoptes/endpoints/base_endpoint.rb#L75
        allow(panoptes_endpoint_double).to receive(:delete).and_raise(Panoptes::Client::ServerError, error_msg)
        allow(job).to receive(:sleep).and_return(0)
      end

      it 'retries up to the number of attempts (default is 3)', :aggregate_failures do
        expect { job.perform(subject_ids, subject_set_id) }.to raise_error(Panoptes::Client::ServerError, error_msg)
        expect(panoptes_endpoint_double).to have_received(:delete).with("/subject_sets/#{subject_set_id}/links/subjects/#{subject_ids.join(',')}").exactly(3).times
      end

      it 'sleeps for a short duration to space out the retry operations', :aggregate_failures do
        expect { job.perform(subject_ids, subject_set_id) }.to raise_error(Panoptes::Client::ServerError, error_msg)
        expect(job).to have_received(:sleep).exactly(2).times
      end

      it 're-raises the error after exhausting all retries' do
        expect { job.perform(subject_ids, subject_set_id, 1) }.to raise_error(Panoptes::Client::ServerError, error_msg)
      end
    end
  end
end
