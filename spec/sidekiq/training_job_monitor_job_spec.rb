# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingJobMonitorJob, type: :job do
  describe 'perform' do
    let(:training_job) do
      TrainingJob.create(
        service_job_url: 'https://bajor-staging.zooniverse.org/training/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: 'https://manifest-host/manifest.csv',
        state: :submitted,
        workflow_id: 1
      )
    end
    let(:training_job_monitor_result) { TrainingJob.new(id: -1) }

    let(:training_job_monitor_service) { instance_double(Batch::Training::MonitorJob) }
    let(:job) { described_class.new }

    before do
      allow(training_job_monitor_service).to receive(:run).and_return(training_job_monitor_result)
      allow(Batch::Training::MonitorJob).to receive(:new).and_return(training_job_monitor_service)
      allow(training_job).to receive(:completed?).and_return(false)
    end

    it 'runs the training job monitor service' do
      job.perform(training_job.id)
      expect(training_job_monitor_service).to have_received(:run)
    end

    it 'reschedules itself if the job has not fininshed' do
      allow(training_job_monitor_result).to receive(:completed?).and_return(false)
      allow(described_class).to receive(:perform_in)
      job.perform(training_job.id)
      expect(described_class).to have_received(:perform_in).with(1.minute, training_job_monitor_result.id)
    end

    context 'when the monitor job returns a completed job' do
      before do
        allow(training_job_monitor_result).to receive(:completed?).and_return(true)
      end

      it 'does not reschedule the monitor job' do
        allow(described_class).to receive(:perform_in)
        job.perform(training_job.id)
        expect(described_class).not_to have_received(:perform_in)
      end
    end

    context 'when the monitor job returns a failure :(' do
      before do
        allow(training_job_monitor_result).to receive(:completed?).and_return(false)
        allow(training_job_monitor_result).to receive(:failed?).and_return(true)
      end

      it 'does not reschedule the monitor job' do
        allow(described_class).to receive(:perform_in)
        job.perform(training_job.id)
        expect(described_class).not_to have_received(:perform_in)
      end
    end

    context 'when the training job has been already completed' do
      before do
        training_job.update_column(:state, 'completed')
      end

      it 'does not run the training job monitor service' do
        job.perform(training_job.id)
        expect(training_job_monitor_service).not_to have_received(:run)
      end
    end
  end
end
