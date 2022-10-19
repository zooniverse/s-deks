# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingDataExport, type: :model do
  let(:attributes) do
    { workflow_id: 1 }
  end
  let(:model) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(model).to be_valid
  end

  it 'is invalid without a state' do
    model.state = nil
    expect(model).to be_invalid
  end

  it 'is invalid without a workflow_id' do
    model.workflow_id = nil
    expect(model).to be_invalid
  end

  describe '#file' do
    it 'has the active storage association' do
      expect(model.file).not_to be_nil
    end
  end

  describe '.storage_path' do
    it 'returns a known path for blob storage location' do
      expected_path = %r{/training/catalogues/test/workflow-1-.*\.csv}
      expect(described_class.storage_path(attributes[:workflow_id])).to match(expected_path)
    end
  end
end
