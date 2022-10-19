# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrainZoobotJob, type: :job do
  describe 'perform' do
    let(:job) { described_class.new }
    let(:workflow_id) { -1 }
    let(:export_training_data_double) { instance_double(Export::TrainingData) }
    let(:batch_training_create_job_double) { instance_double(Batch::Training::CreateJob) }

    before do
      allow(export_training_data_double).to receive(:run)
      allow(Export::TrainingData).to receive(:new).and_return(export_training_data_double)
      allow(batch_training_create_job_double).to receive(:run)
      allow(Batch::Training::CreateJob).to receive(:new).and_return(batch_training_create_job_double)
    end

    # allow the job to load the default workflow id from the env
    it 'defaults the workflow_id to a known env var' do
      default_workflow_id = 3598
      storage_path = TrainingDataExport.storage_path(default_workflow_id)
      allow(TrainingDataExport).to receive(:create!).and_return(TrainingDataExport.new)
      job.perform
      expect(TrainingDataExport).to have_received(:create!).with(storage_path: storage_path, workflow_id: default_workflow_id)
    end

    it 'creates the training data export resource' do
      expect { job.perform(workflow_id) }.to change(TrainingDataExport, :count).by(1)
    end

    it 'runs the training data export service' do
      job.perform(workflow_id)
      expect(export_training_data_double).to have_received(:run).once
    end

    it 'runs the batch training create job service' do
      job.perform(workflow_id)
      expect(batch_training_create_job_double).to have_received(:run).once
    end
  end
end
