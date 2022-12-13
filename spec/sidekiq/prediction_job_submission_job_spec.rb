# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PredictionJobSubmissionJob, type: :job do
  describe 'perform' do
    let(:prediction_job) do
      PredictionJob.create(
        service_job_url: 'https://bajor-staging.zooniverse.org/prediction/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: 'https://manifest-host/manifest.csv',
        state: :pending,
        subject_set_id: 1,
        probability_threshold: 0.5,
        randomisation_factor: 0.5
      )
    end

    let(:prediction_job_create_job_service) { instance_double(Batch::Prediction::CreateJob) }
    let(:job) { described_class.new }

    before do
      allow(prediction_job_create_job_service).to receive(:run).and_return(prediction_job)
      allow(Batch::Prediction::CreateJob).to receive(:new).and_return(prediction_job_create_job_service)
    end

    it 'runs the prediction job create job service' do
      job.perform(prediction_job.id)
      expect(prediction_job_create_job_service).to have_received(:run)
    end

    context 'when the prediction job submitted successfully' do
      before do
        allow(prediction_job).to receive(:failed?).and_return(false)
      end

      it 'queues a PredictionJobMonitorJob in the background if job submitted successfully' do
        allow(PredictionJobMonitorJob).to receive(:perform_in)
        job.perform(prediction_job.id)
        expect(PredictionJobMonitorJob).to have_received(:perform_in).with(10.minutes, prediction_job.id)
      end
    end

    context 'when the prediction job failed to submit' do
      before do
        allow(prediction_job).to receive(:failed?).and_return(true)
      end

      it 'does not queue a PredictionJobMonitorJob in the background if job fails to submit', :aggregate_failures do
        allow(PredictionJobMonitorJob).to receive(:perform_in)
        expect { job.perform(prediction_job.id) }.to raise_error(PredictionJobSubmissionJob::Failure)
        expect(PredictionJobMonitorJob).not_to have_received(:perform_in)
      end
    end
  end
end
