# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveSubjectFromSubjectSetJob, type: :job do
  describe 'perform' do
    let(:subject_id) { 1 }
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
      job.perform(subject_id, subject_set_id)
      expect(panoptes_endpoint_double).to have_received(:delete).with("/subject_sets/#{subject_set_id}/links/subjects/#{subject_id}")
    end
  end
end
