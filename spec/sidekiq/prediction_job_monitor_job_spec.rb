# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PredictionJobMonitorJob, type: :job do
  describe 'perform' do
    let(:prediction_job) do
      PredictionJob.create(
        service_job_url: 'https://bajor-staging.zooniverse.org/prediction/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: 'https://manifest-host/manifest.csv',
        state: :submitted,
        subject_set_id: 1,
        probability_threshold: 0.5,
        randomisation_factor: 0.5
      )
    end
    let(:prediction_job_monitor_results) { PredictionJob.new(id: -1) }

    let(:prediction_job_monitor_service) { instance_double(Batch::Prediction::MonitorJob) }
    let(:job) { described_class.new }

    before do
      allow(prediction_job_monitor_service).to receive(:run).and_return(prediction_job_monitor_results)
      allow(Batch::Prediction::MonitorJob).to receive(:new).and_return(prediction_job_monitor_service)
      allow(prediction_job).to receive(:completed?).and_return(false)
    end

    it 'runs the prediction job monitor service' do
      job.perform(prediction_job.id)
      expect(prediction_job_monitor_service).to have_received(:run)
    end

    it 'reschedules itself if the job has not fininshed' do
      allow(prediction_job_monitor_results).to receive(:completed?).and_return(false)
      allow(described_class).to receive(:perform_in)
      job.perform(prediction_job.id)
      expect(described_class).to have_received(:perform_in).with(1.minute, prediction_job_monitor_results.id)
    end

    context 'when the monitor job returns a completed job' do
      before do
        allow(prediction_job_monitor_results).to receive(:completed?).and_return(true)
      end

      it 'schedules a process prediction results job' do
        allow(ProcessPredictionResultsJob).to receive(:perform_async)
        job.perform(prediction_job.id)
        expect(ProcessPredictionResultsJob).to have_received(:perform_async).with(prediction_job_monitor_results.id)
      end
    end

    context 'when the monitor job returns a failure :(' do
      before do
        allow(prediction_job_monitor_results).to receive(:completed?).and_return(false)
        allow(prediction_job_monitor_results).to receive(:failed?).and_return(true)
      end

      it 'does not reschedule the monitor job' do
        allow(described_class).to receive(:perform_in)
        job.perform(prediction_job.id)
        expect(described_class).not_to have_received(:perform_in)
      end
    end

    context 'when the prediction job has been already completed' do
      before do
        prediction_job.update_column(:state, 'completed')
      end

      it 'does not run the prediction job monitor service' do
        job.perform(prediction_job.id)
        expect(prediction_job_monitor_service).not_to have_received(:run)
      end
    end
  end
end
