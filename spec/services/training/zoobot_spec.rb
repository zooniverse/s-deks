# frozen_string_literal: true

require 'rails_helper'
require 'bajor/client'

RSpec.describe Training::Zoobot do
  describe '#run' do
    let(:manifest_path) { 'a/shared/blob/storage/path.csv' }
    let(:bajor_client_double) { instance_double(Bajor::Client) }
    let(:zoobot) { described_class.new(manifest_path, bajor_client_double) }

    before do
      allow(bajor_client_double).to receive(:train)
    end

    it 'does not raise unexpected errors' do
      expect { zoobot.run }.not_to raise_error
    end

    it 'calls the bajor client service with the correct manifest_path' do
      zoobot.run
      expect(bajor_client_double).to have_received(:train).with(manifest_path).once
    end
  end
end
