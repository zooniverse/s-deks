# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelExtractors::GalaxyZoo do
  let(:task_schema_lookup_key) { 'T0' }
  let(:data_payload) do
    {
      '0' => 3, # smooth
      '1' => 9, # features or disk
      '2' => 0  # star or artifact
    }
  end

  describe '#extract' do
    let(:extractor_instance) { described_class.new(task_schema_lookup_key) }
    let(:extracted_labels) { extractor_instance.extract(data_payload) }
    let(:expected_labels) do
      {
        'smooth-or-featured_smooth' => 3,
        'smooth-or-featured_featured-or-disk' => 9,
        'smooth-or-featured_artifact' => 0
      }
    end

    it 'converts the keys to labels list' do
      extracted_labels = extractor_instance.extract(data_payload)
      expect(extracted_labels).to match(expected_labels)
    end

    it 'raises an error if the payload data key is not known' do
      unknown_key_payload = data_payload.merge('3' => 0)
      expect {
        extractor_instance.extract(unknown_key_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnknownLabelKey, 'key not found: 3')
    end

    it 'raises an error if the task key is not found in the known schema' do
      expect {
        described_class.new('T12').extract(data_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnknownTaskKey, 'key not found: T12')
    end
  end
end
