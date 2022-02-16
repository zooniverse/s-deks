# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Context, type: :model do
  let(:attributes) do
    { project_id: 1, workflow_id: 1 }
  end
  let(:context) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(context).to be_valid
  end

  it 'does not allow duplicates' do
    context.save!
    dup = described_class.new(attributes)
    expect(dup).to be_invalid
    expect(dup.errors[:workflow_id]).to include('Workflow and project must be unique')
  end

  describe '.subjects' do
    it 'correctly links the association' do
      context.save
      subject_model = Subject.create({ subject_id: 1, context_id: context.id })
      expect(context.subjects).to match_array([subject_model])
    end
  end
end
