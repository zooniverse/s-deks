# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelExtractors::GalaxyZoo do
  let(:data_label_schema) do
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
        '3' => '4',
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
      expect(described_class.data_labels).to match(data_label_schema)
    end
  end

  describe '#question_answers_schema' do
    it 'returns the correct set of header' do
      expected_column_headers = %w[dr5 dr8].map do |data_catalog_release|
        described_class.label_prefixes.map do |task_key, question_prefix|
          described_class.data_labels[task_key].values.map { |answer_suffix| "#{question_prefix}-#{data_catalog_release}_#{answer_suffix}"}
        end
      end
      expect(described_class.question_answers_schema).to match(expected_column_headers.flatten)
    end
  end

  context 'with a different current data release suffix override' do
    let(:data_release_suffix) { 'dr12' }
    let(:extractor_instance) { described_class.new('T0', data_release_suffix) }
    let(:expected_labels) { { 'smooth-or-featured-dr12_smooth' => 3 } }

    it 'uses the overriden data release suffix in the derived labels' do
      extracted_labels = extractor_instance.extract({ '0' => 3 })
      expect(extracted_labels).to match(expected_labels)
    end
  end

  describe '#extract' do
    # sample payload mimicing the various choices across all GZ decision tree tasks
    # NOTE: length must not exceed the smallest schema choice list (or use custom data payloads matching each task)
    let(:data_payload) { { '0' => 3, '1' => 9 } }

    described_class.label_prefixes.each do |task_lookup_key, label_prefix|
      # manually construct the expected lables for tests
      def expected_labels(label_prefix, task_lookup_key, payload)
        payload.transform_keys do |key|
          "#{label_prefix}-dr8_#{data_label_schema.dig(task_lookup_key, key)}"
        end
      end

      it 'correctly converts the payload label keys' do
        extracted_labels = described_class.new(task_lookup_key).extract(data_payload)
        expect(extracted_labels).to match(expected_labels(label_prefix, task_lookup_key, data_payload))
      end
    end

    it 'raises an error if the payload data key is not known' do
      unknown_key_payload = data_payload.merge('3' => 0)
      expect {
        # T0 has 3 choices (0, 1, 2)
        described_class.new('T0').extract(unknown_key_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnknownLabelKey, 'key not found: 3')
    end

    it 'raises an error if the task key is not found in the known schema' do
      expect {
        # T12 is unknonw in this schema
        described_class.new('T12').extract(data_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnknownTaskKey, 'key not found: T12')
    end
  end
end
