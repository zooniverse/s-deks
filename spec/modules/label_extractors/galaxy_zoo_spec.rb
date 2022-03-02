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

    it 'converts the keys to labels list' do
      extracted_labels = described_class.extract(data_payload)
      expected_labels = ['smooth', 'features or disk', 'star or artifact']
      expect(extracted_labels).to match_array(expected_labels)
    end

    it 'raises and error if the key is not known' do
      unknown_key_payload = data_payload.merge('3' => 0)
      expect {
        described_class.extract(unknown_key_payload)
      }.to raise_error(LabelExtractors::GalaxyZoo::UnkonwnLabelKey, 'key not found: "3"')
    end
  end
end
