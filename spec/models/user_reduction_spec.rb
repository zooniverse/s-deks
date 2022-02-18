# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserReduction, type: :model do
  let(:raw_payload) do
    {
      'id' => 4,
      'reducible' => {
        'id' => 4,
        'type' => 'Workflow'
      },
      'data' => {
        '0' => 3,
        '1' => 9,
        '2' => 0,
        '3' => 3
      },
      'subject' => {
        'id' => 4,
        'metadata' => {},
        'created_at' => '2021-08-06T11:08:53.918Z',
        'updated_at' => '2021-08-06T11:08:53.918Z'
      },
      'created_at' => '2021-08-06T11:08:54.000Z',
      'updated_at' => '2021-08-06T11:08:54.000Z'
    }
  end
  let(:attributes) do
    { subject_id: 4, workflow_id: 4, labels: %w[bear plane], raw_payload: raw_payload }
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

  describe '.unpack_from_raw_payload' do
    xit 'add feature here to convert the raw reduction payload to the model data' do
      # this will be used to ingest data and will be called in an operation before save
    end
  end

  describe '.subject' do
    fixtures :contexts
    let(:subject_model) { Subject.create({ subject_id: 4, context_id: 1 }) }
    let(:user_reduction) do
      described_class.new({ subject_id: subject_model.id, workflow_id: 4, labels: %w[bear plane], raw_payload: raw_payload })
    end

    it 'correctly links the association' do
      expect(user_reduction.subject).to eq(subject_model)
    end
  end
end
