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

    describe 'allow the job to load the default context workflow id' do
      fixtures :contexts
      let(:context) { Context.first }
      let(:workflow_id) { context.workflow_id }
      let(:storage_path) { TrainingDataExport.storage_path(workflow_id) }

      before do
        allow(ENV).to receive(:fetch).with('ZOOBOT_GZ_CONTEXT_ID').and_return(context.id)
      end

      it 'defaults the workflow_id to a known env var' do
        allow(TrainingDataExport).to receive(:create!).and_return(TrainingDataExport.new)
        job.perform
        expect(TrainingDataExport).to have_received(:create!).with(storage_path: storage_path, workflow_id: workflow_id)
      end
    end

    context 'with existing training data exports' do
      it 'finds and reuses the existing training data export created less than 12 hours ago' do
        training_data_export = TrainingDataExport.create!(workflow_id: workflow_id, created_at: 11.hours.ago, storage_path: 'test', state: :finished)
        expect(job.find_recent_training_data_export(workflow_id)).to eq(training_data_export)
      end

      it 'does not find or reus and existing training data export created more than 12 hours ago' do
        TrainingDataExport.create!(workflow_id: workflow_id, created_at: (12.hours + 1.minute).ago, storage_path: 'test', state: :finished)
        expect(job.find_recent_training_data_export(workflow_id)).to be_nil
      end
    end
  end
end
