# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserReduction, type: :model do
  let(:attributes) do
    { subject_id: 4, workflow_id: 4, labels: %w[bear plane], raw_payload: {} }
  end
  let(:user_reduction) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(user_reduction).to be_valid
  end

  it 'is invalid without a subject_id' do
    user_reduction.subject_id = nil
    expect(user_reduction).to be_invalid
  end

  it 'is invalid for duplicate subjects for the same workflow' do
    user_reduction.save!
    dup = described_class.new(attributes)
    dup.valid?
    expect(dup.errors[:subject_id]).to include('UserReduction must be unique for the subject and workflow')
  end

  describe '.subject' do
    fixtures :contexts
    let(:subject_model) { Subject.create({ subject_id: 4, context_id: 1 }) }
    let(:user_reduction) do
      described_class.new({ subject_id: subject_model.id, workflow_id: 4 })
    end

    it 'correctly links the association' do
      expect(user_reduction.subject).to eq(subject_model)
    end
  end
end
