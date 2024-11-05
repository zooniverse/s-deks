# spec/models/label_extractors/base_extractor_spec.rb

class TestExtractor < LabelExtractors::GalaxyZoo::BaseExtractor
  TASK_KEY_LABEL_PREFIXES = { task_key_example: "example_prefix" }
  TASK_KEY_DATA_LABELS = { task_key_example: { "T0" => "example_label" } }
  def self.data_release_suffix
    "v1"
  end
end

RSpec.describe LabelExtractors::GalaxyZoo::BaseExtractor do
  let(:task_lookup_key) { :task_key_example }
  let(:data_hash) { { "T0" => "example_key" } }
  let(:instance) { TestExtractor.new(task_lookup_key) }

  describe '#initialize' do
    it 'initializes with task_lookup_key and sets task_prefix_label' do
      expect(instance.task_lookup_key).to eq(task_lookup_key)
      expect(instance.task_prefix_label).to eq("example_prefix")
    end
  end

  describe '#extract' do
    it 'transforms the data hash keys correctly' do
      result = instance.extract(data_hash)
      expect(result).to eq({ "example_prefix-v1_example_label" => "example_key" })
    end
  end

  describe '#task_prefix' do
    it 'returns the correct prefix for a known task_lookup_key' do
      expect(instance.send(:task_prefix)).to eq("example_prefix")
    end

    it 'raises an error for an unknown task_lookup_key' do
      invalid_instance = TestExtractor.allocate # Skips calling initialize
      allow(invalid_instance).to receive(:task_lookup_key).and_return(:invalid_key)
      expect { invalid_instance.send(:task_prefix) }.to raise_error(LabelExtractors::GalaxyZoo::UnknownTaskKey)
    end
  end

  describe '#data_payload_label' do
    it 'returns the correct label for a known key' do
      expect(instance.send(:data_payload_label, "T0")).to eq("example_label")
    end

    it 'raises an error for an unknown key' do
      expect { instance.send(:data_payload_label, "unknown_key") }.to raise_error(LabelExtractors::GalaxyZoo::UnknownLabelKey)
    end
  end
end
