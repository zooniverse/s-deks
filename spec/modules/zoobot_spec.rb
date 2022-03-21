# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zoobot do
  let(:image_url) do
    'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg'
  end

  describe '.training_image_path' do
    let(:expected_path) { 'training_images/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }

    it 'converts the url to a training container path' do
      extracted_path = described_class.training_image_path(image_url)
      expect(extracted_path).to eq(expected_path)
    end
  end

  describe '.container_image_path' do
    let(:expected_path) { '/test/training_images/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }

    it 'converts the url to a training container path' do
      extracted_path = described_class.container_image_path(image_url)
      expect(extracted_path).to eq(expected_path)
    end
  end

  describe '.storage_path_key' do
    let(:exported_workflow_id) { 4 }
    let(:expected_path_key) { "/test/training_catalogues/workflow-#{exported_workflow_id}" }

    it 'converts the url to a training container path' do
      extracted_path_key = described_class.storage_path_key(exported_workflow_id)
      expect(extracted_path_key).to eq(expected_path_key)
    end
  end
end
