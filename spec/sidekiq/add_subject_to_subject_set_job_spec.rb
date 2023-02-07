# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddSubjectToSubjectSetJob, type: :job do
  describe 'perform' do
    let(:subject_id) { 1 }
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
      job.perform(subject_id, subject_set_id)
      expect(panoptes_client_double).to have_received(:add_subjects_to_subject_set).with(subject_set_id, [subject_id])
    end
  end
end
