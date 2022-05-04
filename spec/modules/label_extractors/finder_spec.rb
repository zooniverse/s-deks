# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LabelExtractors::Finder do
  let(:task_schema_lookup_key) { 'galaxy_zoo_t0' }

  describe '.extractor_instance' do
    it 'returns the correct label extractor type' do
      label_extractor = described_class.extractor_instance(task_schema_lookup_key)
      expect(label_extractor).to be_a(LabelExtractors::GalaxyZoo)
    end

    it 'raises an error if the extractor class is unknown' do
      expect {
        described_class.extractor_instance('unknown_project_t0')
      }.to raise_error(LabelExtractors::Finder::UknownExtractor, "no extractor class found for 'unknown_project'")
    end

    it 'correctly sets the task_lookup_key' do
      label_extractor = described_class.extractor_instance(task_schema_lookup_key)
      expect(label_extractor.task_lookup_key).to eq('T0')
    end

    it 'raises an error if the task key is not known for the label schema' do
      expect {
        described_class.extractor_instance('galaxy_zoo_t50')
      }.to raise_error(LabelExtractors::GalaxyZoo::UnknownTaskKey, 'key not found: T50')
    end
  end
end
