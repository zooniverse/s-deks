# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Batch::Training::MonitorJob do
  describe '#run' do
    let(:manifest_url) { 'https://manifest-host.zooniverse.org/manifest.csv' }
    let(:training_job) do
      TrainingJob.new(
        service_job_url: 'https://bajor-staging.zooniverse.org/training/job/64bf4fab-ed6d-4f9a-b8ae-004086e3676f',
        manifest_url: manifest_url,
        state: :submitted,
        workflow_id: 1
      )
    end
    let(:bajor_client_double) { instance_double(Bajor::Client) }
    let(:training_monitor_job) { described_class.new(training_job, bajor_client_double) }
    let(:job_id) { '64bf4fab-ed6d-4f9a-b8ae-004086e3676f' }
    let(:results_url) do
      'https://kadeactivelearning.blob.core.windows.net/training/jobs/2022-10-21T07%3A39_64bf4fab-ed6d-4f9a-b8ae-004086e3676f/results/'
    end

    context 'when bajor client training_job_results is nil (jobs still active)' do
      before do
        allow(bajor_client_double).to receive(:training_job_results).with(job_id).and_return(nil)
      end

      it 'does not modify the training_job state' do
        expect { training_monitor_job.run }.not_to change(training_job, :state)
      end
    end

    context 'when bajor client training_job_results is the result url (jobs tasks all completed ok)' do
      before do
        allow(bajor_client_double).to receive(:training_job_results).with(job_id).and_return(results_url)
      end

      it 'updates the on training job resource to match the blob storage URL for the results file' do
        expect {
          training_monitor_job.run
        }.to change(training_job, :results_url).from('').to(results_url)
      end

      it 'updates the state tracking info on the training job resource' do
        expect {
          training_monitor_job.run
        }.to change(training_job, :state).from('submitted').to('completed')
      end
    end

    context 'when bajor client training_job_results raises an error (one of the job tasks failed)' do
      before do
        allow(bajor_client_double)
          .to receive(:training_job_results).with(job_id)
          .and_raise(Bajor::Client::TrainingJobTaskError, 'job failed for some reason :sad_panda:')
      end

      it 'does not updates the results_url on training job resource' do
        expect {
          training_monitor_job.run
        }.not_to change(training_job, :results_url)
      end

      it 'updates the state tracking info on the training job resource' do
        expect {
          training_monitor_job.run
        }.to change(training_job, :state).from('submitted').to('failed')
      end
    end
  end
end
