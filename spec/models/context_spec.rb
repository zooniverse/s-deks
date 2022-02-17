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

  it 'does not allow duplicate workflow project ids' do
    context.save!
    dup = described_class.new(attributes)
    dup.valid?
    expect(dup.errors[:workflow_id]).to include('Workflow and project must be unique')
  end

  it 'does not raise an error deleting without subjects' do
    expect { context.destroy }.not_to raise_error
  end

  describe '.subjects' do
    let(:subject_model) do
      Subject.create({ subject_id: 1, context_id: context.id })
    end

    before do
      context.save
      subject_model
    end

    it 'correctly links the association' do
      expect(context.subjects).to match_array([subject_model])
    end

    it 'raises an error when destroying' do
      expect { context.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError, 'Cannot delete record because of dependent subjects')
    end
  end
end
