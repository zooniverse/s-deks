# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  let(:attributes) do
    { subject_id: 1, workflow_id: 2, project_id: 3 }
  end
  let(:model) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(model).to be_valid
  end

  it 'is invalid without a subject_id' do
    model.subject_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid without a workflow_id' do
    model.workflow_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid without a project_id' do
    model.project_id = nil
    expect(model).to be_invalid
  end
end
