# frozen_string_literal: true

class PredictionJobSubmissionJob
  class Failure < StandardError; end

  include Sidekiq::Job

  PREDICTION_JOB_MONITOR = ENV.fetch('PREDICTION_JOB_MONITOR', 10).to_i

  def perform(prediction_job_id)
    prediction_job = PredictionJob.find(prediction_job_id)

    # return early if the job has already been submitted or is done
    return if prediction_job.submitted? || prediction_job.completed?

    prediction_job = Batch::Prediction::CreateJob.new(prediction_job).run

    # raise a failure here to rely on sidekiq to retry the job
    # and notify us that there are issues with job submission
    # Note: if this gets noisy we can look at silencing the error reporting
    raise Failure, "failure when submiting the prediction job with id: #{prediction_job.id}" if prediction_job.failed?

    # kick off a job monitor here that updates the
    # prediction job resource with the job tasks results
    PredictionJobMonitorJob.perform_in(PREDICTION_JOB_MONITOR.minutes, prediction_job.id)

    prediction_job
  end
end
