# frozen_string_literal: true

require 'rails_helper'
require 'bajor/client'

RSpec.describe Batch::Prediction::ExportManifest do
  describe '#run', :focus do
    let(:subject_set_id) { 1 }
    let(:panoptes_client_double) { instance_double(Panoptes::Client) }
    let(:service) { described_class.new(subject_set_id, panoptes_client_double) }

    before do
      allow(panoptes_client_double).to receive(:subject_set)
    end

    it 'does not raise unexpected errors' do
      expect { service.run }.not_to raise_error
    end

    xit 'calls the panoptes client to find the subject set' do
      service.run
      expect(panoptes_client_double).to have_received(:subject_set).with(subject_set_id).once
    end

    xit 'calls the panoptes client to iterate over the subjects' do
      service.run
      expect(panoptes_client_double).to have_received(:test).with(subject_set_id).once
    end

    xit 'creates an exported manifest' do
    end
  end
end
