# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::TrainingDataSync do
  describe '#run' do
    let(:src_image_url) do
      'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg'
    end
    let(:data_syncer) { described_class.new(src_image_url) }
    let(:blob_destination_path) { Zoobot.training_image_path(src_image_url) }
    let(:blob_service_client_double) { instance_double(Azure::Storage::Blob::BlobService) }
    let(:blob_instance_double) { instance_double(Azure::Storage::Blob::Blob) }
    let(:blob_copy_properties) do
      {
        blob_type: 'BlockBlob',
        copy_id: '6569935c-a8a1-4f90-819a-e4258271e163',
        copy_status: 'pending',
        copy_source: src_image_url,
        copy_progress: '0/551722',
        copy_completion_time: nil,
        copy_status_description: nil
      }
    end

    before do
      # call ActiveStorage::Blob.service before any debugg statement
      # to ensure we load the service correctly
      allow(blob_service_client_double).to receive(:copy_blob_from_uri)
      allow(blob_service_client_double).to receive(:get_blob_properties).and_return(blob_instance_double)
      allow(blob_instance_double).to receive(:properties).and_return(blob_copy_properties)
      allow(Azure::Storage::Blob::BlobService).to receive(:create).and_return(blob_service_client_double)
    end

    it 'copies the src file to the destination container' do
      data_syncer.run
      expect(blob_service_client_double).to have_received(:copy_blob_from_uri).with(Rails.env, blob_destination_path, src_image_url)
    end

    context 'when the blob is already copied' do
      let(:blob_copy_properties) do
        {
          blob_type: 'BlockBlob',
          copy_id: '6569935c-a8a1-4f90-819a-e4258271e163',
          copy_status: 'success',
          copy_source: src_image_url,
          copy_progress: '551722/551722',
          copy_completion_time: 'Mon, 21 Mar 2022 13:36:38 GMT',
          copy_status_description: nil
        }
      end

      it 'does not call the blob copy uri function' do
        data_syncer.run
        expect(blob_service_client_double).not_to have_received(:copy_blob_from_uri)
      end
    end
  end
end
