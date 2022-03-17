# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingDataExporterJob, type: :job do
  describe 'perform' do
    let(:training_data_export) { TrainingDataExport.create(workflow_id: 369) }
    let(:job) { described_class.new }

    it 'runs the training data export service' do
      training_data_export_service = instance_double(Export::TrainingData)
      allow(training_data_export_service).to receive(:run)
      allow(Export::TrainingData).to receive(:new).with(TrainingDataExport).and_return(training_data_export_service)
      job.perform(training_data_export.id)
      expect(training_data_export_service).to have_received(:run)
    end
  end
end

