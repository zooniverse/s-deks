# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::TrainingDataSync do
  describe '#run' do
    let(:src_image_url) do
      'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg'
    end
    let(:data_syncer) { described_class.new(src_image_url) }
    let(:blob_destination_path) { Zoobot.training_image_path(src_image_url) }
    let(:blob_service_double) { instance_double(Azure::Storage::Blob::BlobService) }

    before do
      # call ActiveStorage::Blob.service before any debugg statement
      # to ensure we load the service correctly
      allow(blob_service_double).to receive(:copy_blob_from_uri)
      allow(Azure::Storage::Blob::BlobService).to receive(:create).and_return(blob_service_double)
    end

    it 'copies the src file to the destination container', :focus do
      data_syncer.run
      expect(blob_service_double).to have_received(:copy_blob_from_uri).with(Rails.env, blob_destination_path, src_image_url)
    end
  end
end
