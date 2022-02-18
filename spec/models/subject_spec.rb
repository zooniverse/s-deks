# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  fixtures :contexts

  let(:attributes) do
    { subject_id: 1, context_id: 1 }
  end
  let(:model) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(model).to be_valid
  end

  it 'is invalid without a subject_id' do
    model.subject_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid without a context_id' do
    model.context_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid for duplicate subjects in the same context' do
    model.save!
    dup = described_class.new(attributes)
    dup.valid?
    expect(dup.errors[:subject_id]).to include('Subject must be unique for the context')
  end

  describe '.context' do
    it 'correctly links the association' do
      expect(model.context).to be_valid
    end
  end

  describe '.user_reductions' do
    let(:user_reduction) do
      UserReduction.create({ subject_id: model.id, workflow_id: 4, labels: %w[bear plane], raw_payload: {} })
    end

    before do
      model.save!
      user_reduction
    end

    it 'correctly links the association' do
      expect(model.user_reductions).to match_array(user_reduction)
    end

    it 'raises an error when destroying' do
      expect { model.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError, 'Cannot delete record because of dependent user_reductions')
    end
  end
end
