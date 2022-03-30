# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::Subject do
  fixtures :contexts

  let(:context) { Context.first }
  let(:zooniverse_subject_id) { 931 }
  let(:subject_import_service) do
    described_class.new(zooniverse_subject_id, context)
  end

  describe '.run' do
    it 'creates a valid subject resource' do
      subject_instance = subject_import_service.run
      expect(subject_instance).to be_valid
    end

    it 'queues a data backfilling worker' do
      allow(SubjectBackfillerJob).to receive(:perform_async)
      subject_import_service.run
      expect(SubjectBackfillerJob).to have_received(:perform_async).with(Integer)
    end

    it 'does not create subjects that already exist' do
      # long term may want to look at upserts here
      # but short term the subject data should be static
      existing_subject = Subject.create(zooniverse_subject_id: zooniverse_subject_id, context_id: context.id)
      subject_instance = subject_import_service.run
      expect(subject_instance).to eq(existing_subject)
    end
  end
end
