# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Batch::Prediction::MonitorJob do
  describe '#run' do
    let(:manifest_url) { 'https://manifest-host.zooniverse.org/manifest.csv' }
    let(:prediction_job) do
      PredictionJob.new(
        service_job_url: 'https://bajor-staging.zooniverse.org/prediction/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: manifest_url,
        state: :submitted,
        subject_set_id: 1,
        probability_threshold: 0.5,
        randomisation_factor: 0.5
      )
    end
    let(:bajor_client_double) { instance_double(Bajor::Client) }
    let(:prediction_monitor_job) { described_class.new(prediction_job, bajor_client_double) }
    let(:results_url) do
      'https://kadeactivelearning.blob.core.windows.net/predictions/jobs/2022-10-21T07%3A39_64bf4fab-ed6d-4f9a-b8ae-004086e3676f/results/predictions.csv'
    end
    let(:job_id) { '64bf4fab-ed6d-4f9a-b8ae-004086e3676f' }

    context 'when bajor client prediction_job_results is nil (jobs still active)' do
      before do
        allow(bajor_client_double).to receive(:prediction_job_results).with(job_id).and_return(nil)
      end

      it 'does not modify the prediction_job state' do
        expect { prediction_monitor_job.run }.not_to change(prediction_job, :state)
      end
    end

    context 'when bajor client prediction_job_results is the result url (jobs tasks all completed ok)' do
      before do
        allow(bajor_client_double).to receive(:prediction_job_results).with(job_id).and_return(results_url)
      end

      it 'updates the results_url on prediction job resource to match the blob storage URL for the results file' do
        expect {
          prediction_monitor_job.run
        }.to change(prediction_job, :results_url).from('').to(results_url)
      end

      it 'updates the state tracking info on the prediction job resource' do
        expect {
          prediction_monitor_job.run
        }.to change(prediction_job, :state).from('submitted').to('completed')
      end
    end

    context 'when bajor client prediction_job_results raises an error (one of the job tasks failed)' do
      before do
        allow(bajor_client_double)
          .to receive(:prediction_job_results).with(job_id)
          .and_raise(Bajor::Client::PredictionJobTaskError, 'job failed for some reason :sad_panda:')
      end

      it 'does not updates the results_url on prediction job resource' do
        expect {
          prediction_monitor_job.run
        }.not_to change(prediction_job, :results_url)
      end

      it 'updates the state tracking info on the prediction job resource' do
        expect {
          prediction_monitor_job.run
        }.to change(prediction_job, :state).from('submitted').to('failed')
      end
    end
  end
end
