# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelExtractors::GalaxyZoo do
  let(:data_payload) do
    {
      '0' => 3, # smooth
      '1' => 9, # features or disk
      '2' => 0  # star or artifact
    }
  end

  describe '.extract' do
    let(:extracted_labels) { described_class.extract(data_payload) }
    let(:expected_labels) do
      {
        'smooth-or-featured_smooth' => 3,
        'smooth-or-featured_featured-or-disk' => 9,
        'smooth-or-featured_artifact' => 0
      }
    end

    it 'converts the keys to labels list' do
      extracted_labels = described_class.extract(data_payload)
      expect(extracted_labels).to match(expected_labels)
    end

    it 'raises and error if the key is not known' do
      unknown_key_payload = data_payload.merge('3' => 0)
      expect {
        described_class.extract(unknown_key_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnkonwnLabelKey, 'key not found: 3')
    end
  end
end
