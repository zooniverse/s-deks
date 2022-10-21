# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PredictionJobMonitorJob, type: :job do
  describe 'perform' do
    let(:prediction_job) do
      PredictionJob.create(
        service_job_url: 'https://bajor-staging.zooniverse.org/prediction/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: 'https://manifest-host/manifest.csv',
        state: :submitted
      )
    end

    let(:prediction_job_monitor_service) { instance_double(Batch::Prediction::MonitorJob) }
    let(:job) { described_class.new }

    before do
      allow(prediction_job_monitor_service).to receive(:run).and_return(prediction_job)
      allow(Batch::Prediction::MonitorJob).to receive(:new).and_return(prediction_job_monitor_service)
      allow(prediction_job).to receive(:completed?).and_return(false)
    end

    it 'runs the prediction job monitor service' do
      job.perform(prediction_job.id)
      expect(prediction_job_monitor_service).to have_received(:run)
    end

    it 'reschedules itself if the job has not fininshed' do
      allow(prediction_job).to receive(:completed?).and_return(false)
      allow(PredictionJobMonitorJob).to receive(:perform_in)
      job.perform(prediction_job.id)
      expect(PredictionJobMonitorJob).to have_received(:perform_in).with(1.minute, prediction_job.id)
    end

    context 'when the prediction job has been completed' do
      before do
        allow(prediction_job).to receive(:completed?).and_return(false)
      end

      it 'does not run the prediction job monitor service' do
        prediction_job.update_column(:state, :completed)
        job.perform(prediction_job.id)
        expect(prediction_job_monitor_service).not_to have_received(:run)
      end
    end
  end
end
