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
end
