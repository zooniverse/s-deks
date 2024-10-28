
# spec/label_extractors/galaxy_zoo/cosmic_dawn_and_euclid_spec.rb
class TestClass < LabelExtractors::Shared::CosmicDawnAndEuclid
    TASK_KEY_LABEL_PREFIXES = { task_key_example: "example_prefix" }
    TASK_KEY_DATA_LABELS = { task_key_example: { "T0" => "example_label" } }

    def self.data_release_suffix
      "v1"
    end
end

RSpec.describe LabelExtractors::Shared::CosmicDawnAndEuclid do
  let(:task_lookup_key) { :task_key_example }

  # Define a dynamic subclass of CosmicDawnAndEuclid for testing
  let(:test_class) do
    Class.new(described_class) do
      TASK_KEY_LABEL_PREFIXES = { task_key_example: "example_prefix" }
      TASK_KEY_DATA_LABELS = { task_key_example: { "T0" => "example_label" } }

      def self.data_release_suffix
        "v1"
      end
    end
  end

  let(:instance) { test_class.new(task_lookup_key) }

  describe 'question_answers_schema' do
    it 'constructs the correct question and answers schema' do
      result = TestClass.question_answers_schema
      expected_result = ["example_prefix-v1_example_label"]
      expect(result).to eq(expected_result)
    end
  end

  describe 'data_release_suffix' do
    it 'raises NotImplementedError when not overridden' do
      # We directly call the described class here without using the test_class
      expect { described_class.data_release_suffix }.to raise_error(NotImplementedError)
    end
  end
end

