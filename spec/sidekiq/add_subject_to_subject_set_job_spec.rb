# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddSubjectToSubjectSetJob, type: :job do
  describe 'perform' do
    let(:subject_ids) { [1, 2] }
    let(:subject_set_id) { 2 }
    let(:job) { described_class.new }
    let(:panoptes_client_double) { instance_double(Panoptes::Client) }

    before do
      allow(ENV).to receive(:fetch).with('PANOPTES_OAUTH_CLIENT_ID').and_return('fake-client-id')
      allow(ENV).to receive(:fetch).with('PANOPTES_OAUTH_CLIENT_SECRET').and_return('fake-client-sekreto')
      allow(panoptes_client_double).to receive(:add_subjects_to_subject_set)
      allow(Panoptes::Client).to receive(:new).and_return(panoptes_client_double)
    end

    it 'calls the api client to add the subject to the subject set' do
      job.perform(subject_ids, subject_set_id)
      expect(panoptes_client_double).to have_received(:add_subjects_to_subject_set).with(subject_set_id, subject_ids)
    end

    context 'when the server has an error' do
      let(:error_msg) { '{"errors"=>[{"message"=>"Attempted to update a stale object: SubjectSet."}]}' }

      before do
        # https://github.com/zooniverse/panoptes-client.rb/blob/bf0cffdf87b96bc97ed1924a09bb924d7c80d79d/lib/panoptes/endpoints/base_endpoint.rb#L75
        allow(panoptes_client_double).to receive(:add_subjects_to_subject_set).and_raise(Panoptes::Client::ServerError, error_msg)
        allow(job).to receive(:sleep).and_return(0)
      end

      it 'retries up to the number of attempts (default is 3)', :aggregate_failures do
        expect { job.perform(subject_ids, subject_set_id) }.to raise_error(Panoptes::Client::ServerError, error_msg)
        expect(panoptes_client_double).to have_received(:add_subjects_to_subject_set).with(subject_set_id, subject_ids).exactly(3).times
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
