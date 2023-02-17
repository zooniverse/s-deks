# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingDataSyncerJob, type: :job do
  describe 'perform' do
    let(:src_image_url_1) { 'https://example.com/image.jpeg' }
    let(:src_image_url_2) { 'https://example.com/image.png' }
    let(:subject_to_sync) do
      Subject.new(
        id: 1,
        zooniverse_subject_id: 99,
        context_id: 1,
        locations: [{ 'image/jpeg': src_image_url_1 }, { 'image/png': src_image_url_2 }]
      )
    end

    let(:training_data_sync_service_1) { instance_double(Storage::TrainingDataSync) }
    let(:training_data_sync_service_2) { instance_double(Storage::TrainingDataSync) }
    let(:job) { described_class.new }

    before do
      subject_to_sync
      allow(Subject).to receive(:find).with(subject_to_sync.id).and_return(subject_to_sync)
      allow(training_data_sync_service_1).to receive(:run)
      allow(training_data_sync_service_2).to receive(:run)
      allow(Storage::TrainingDataSync).to receive(:new).with(src_image_url_1).and_return(training_data_sync_service_1)
      allow(Storage::TrainingDataSync).to receive(:new).with(src_image_url_2).and_return(training_data_sync_service_2)
    end

    it 'runs the training data syncer service for the first location' do
      job.perform(subject_to_sync.id)
      expect(training_data_sync_service_1).to have_received(:run).once
    end

    it 'runs the training data syncer service for the second location' do
      job.perform(subject_to_sync.id)
      expect(training_data_sync_service_2).to have_received(:run).once
    end

    context 'when the azure storeage returns an error' do
      before do
        allow(training_data_sync_service_1).to receive(:run).and_raise(Storage::TrainingDataSync::Failure)
        allow(described_class).to receive(:perform_in)
      end

      it 'rescuedules the job' do
        job.perform(subject_to_sync.id)
        expect(described_class).to have_received(:perform_in).with(ActiveSupport::Duration, subject_to_sync.id)
      end
    end
  end
end
