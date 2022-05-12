# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reduction, type: :model do
  let(:attributes) do
    {
      zooniverse_subject_id: 4,
      workflow_id: 4,
      labels: { 'smooth-or-featured_smooth' => 1, 'smooth-or-featured_featured-or-disk' => 3 },
      unique_id: '8000_231121_468',
      raw_payload: {},
      task_key: 'T0'
    }
  end
  let(:reduction) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(reduction).to be_valid
  end

  it 'is invalid without a zooniverse_subject_id' do
    reduction.zooniverse_subject_id = nil
    expect(reduction).to be_invalid
  end

  it 'allows duplicate subjects and workflow with different task keys' do
    reduction.save!
    dup = described_class.new(attributes)
    dup.task_key = 'T1'
    expect(dup.valid?).to be(true)
  end

  it 'is invalid for duplicate subjects, workflow and task keys' do
    reduction.save!
    dup = described_class.new(attributes)
    dup.valid?
    expect(dup.errors[:zooniverse_subject_id]).to include('Reduction must be unique for the zooniverse subject, workflow and task key')
  end

  describe '.subject' do
    fixtures :contexts
    let(:subject_model) { Subject.create({ zooniverse_subject_id: 4, context_id: 1 }) }
    let(:reduction) do
      described_class.new({ subject_id: subject_model.id, workflow_id: 4 })
    end

    it 'correctly links the association' do
      expect(reduction.subject).to eq(subject_model)
    end
  end
end
