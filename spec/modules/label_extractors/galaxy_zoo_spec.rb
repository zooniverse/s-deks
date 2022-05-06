# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelExtractors::GalaxyZoo, :focus do
  let(:data_lable_schema) do
    {
      'T0' => {
        '0' => 'smooth',
        '1' => 'featured-or-disk',
        '2' => 'artifact'
      },
      'T1' => {
        '0' => 'round',
        '1' => 'in-between',
        '2' => 'cigar-shaped'
      },
      'T2' => {
        '0' => 'yes',
        '1' => 'no'
      },
      'T3' => {
        '0' => 'rounded',
        '1' => 'boxy',
        '2' => 'none'
      },
      'T4' => {
        '0' => 'no',
        '1' => 'weak',
        '2' => 'strong'
      },
      'T5' => {
        '0' => 'yes',
        '1' => 'no'
      },
      'T6' => {
        '0' => 'tight',
        '1' => 'medium',
        '2' => 'loose'
      },
      'T7' => {
        '0' => '1',
        '1' => '2',
        '2' => '3',
        '3' => '5',
        '4' => 'more-than-4',
        '5' => 'cant-tell'
      },
      'T8' => {
        '0' => 'none',
        '1' => 'small',
        '2' => 'moderate',
        '3' => 'large',
        '4' => 'dominant'
      },
      'T11' => {
        '0' => 'merger',
        '1' => 'major-disturbance',
        '2' => 'minor-disturbance',
        '3' => 'none'
      }
    }
  end
  let(:label_prefix_schema) do
    {
      'T0' => 'smooth-or-featured',
      'T1' => 'how-rounded',
      'T2' => 'disk-edge-on',
      'T3' => 'edge-on-bulge',
      'T4' => 'bar',
      'T5' => 'has-spiral-arms',
      'T6' => 'spiral-winding',
      'T7' => 'spiral-arm-count',
      'T8' => 'bulge-size',
      'T11' => 'merging' # T10 is not used for training and no T9 :shrug:
    }
  end

  describe '#label_prefixes' do
    it 'has the correct schema label prefixes' do
      expect(described_class.label_prefixes).to match(label_prefix_schema)
    end
  end

  describe '#data_labels' do
    it 'has the correct schema data labels' do
      expect(described_class.data_labels).to match(data_lable_schema)
    end
  end

  context 'with a data release suffix override' do
    let(:data_release_suffix) { 'dr5' }
    let(:extractor_instance) { described_class.new('T0', data_release_suffix) }
    let(:expected_labels) { { 'smooth-or-featured-dr5_smooth' => 3 } }

    it 'uses the overriden data release suffix in the derived lables' do
      extracted_labels = extractor_instance.extract({ '0' => 3 })
      expect(extracted_labels).to match(expected_labels)
    end
  end

  # TODO: flesh this spec out to ensure it works for all lookups keys
  describe '#extract' do
    let(:task_lookup_key) { 'T0' }
    let(:data_payload) do
      {
        '0' => 3, # smooth
        '1' => 9, # features or disk
        '2' => 0  # star or artifact
      }
    end
    let(:extractor_instance) { described_class.new(task_lookup_key) }
    let(:expected_labels) do
      {
        'smooth-or-featured-dr8_smooth' => 3,
        'smooth-or-featured-dr8_featured-or-disk' => 9,
        'smooth-or-featured-dr8_artifact' => 0
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
