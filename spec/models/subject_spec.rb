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

  xit 'is is invalid for duplicate subject ids in the same context' do
    # possible for subjects to reuse across contexts, i.e. has_many
    # but for now let's just scope the subject resouce to the context id
    # as I don't expect this to actually happen with the real world data
    # do the simple data model for now, iterate later if we need it
    #
    # NOTE: subject reuse is very rare across projects in the API
  end

  describe '.context' do
    it 'is invalid without a context_id' do
      model.context_id = nil
      expect(model).to be_invalid
    end

    it 'correctly links the association' do
      expect(model.context).to be_valid
    end
  end
end
