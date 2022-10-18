# frozen_string_literal: true

require 'rails_helper'
require 'bajor/client'

RSpec.describe Batch::Training::CreateJob do
  describe '#run' do
    let(:manifest_path) { 'a/shared/blob/storage/path.csv' }
    let(:bajor_client_double) { instance_double(Bajor::Client) }
    let(:training_create_job) { described_class.new(manifest_path, bajor_client_double) }

    before do
      allow(bajor_client_double).to receive(:create_training_job)
    end

    it 'does not raise unexpected errors' do
      expect { training_create_job.run }.not_to raise_error
    end

    it 'calls the bajor client service with the correct manifest_path' do
      training_create_job.run
      expect(bajor_client_double).to have_received(:create_training_job).with(manifest_path).once
    end
  end
end
