# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingDataExport, type: :model do
  let(:attributes) do
    {}
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

  describe '.file' do
    it 'has the active storage association' do
      expect(model.file).not_to be_nil
    end
  end
end
