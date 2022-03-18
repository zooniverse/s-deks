# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectBackfillerJob, type: :job do
  describe 'perform' do
    let(:existing_subject) do
      Subject.create(zooniverse_subject_id: 123, context_id: 1)
    end
    let(:locations_import_service) { instance_double(Import::SubjectLocations) }
    let(:job) { described_class.new }

    before do
      allow(locations_import_service).to receive(:run)
      allow(Import::SubjectLocations).to receive(:new).with(existing_subject).and_return(locations_import_service)
    end

    it 'calls the import subject locations service' do
      job.perform(existing_subject.id)
      expect(locations_import_service).to have_received(:run)
    end
  end
end

