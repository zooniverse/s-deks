# frozen_string_literal: true

require 'honeybadger/ruby'

class PredictionJobMonitorJob
  class PredictionFailure < StandardError; end
  include Sidekiq::Job

  MONITOR_JOB_RESCHEDULE_DELAY = ENV.fetch('MONITOR_JOB_RESCHEDULE_DELAY', 1).to_i

  def perform(prediction_job_id)
    prediction_job = PredictionJob.find(prediction_job_id)

    # short circuit if we run this on a job that's already done
    return if prediction_job.completed?

    prediction_job = Batch::Prediction::MonitorJob.new(prediction_job).run

    if prediction_job.failed?
      # notify HB about these errors - longer term remove if noisy
      Honeybadger.notify(
        PredictionFailure.new("Prediction Job failed, id: #{prediction_job.id}, message: #{prediction_job.message}")
      )
      return # avoid rescheduling the job if it's failed
    end

    if prediction_job.completed?
      ProcessPredictionResultsJob.perform_async(prediction_job.id)
    else
      # reschedule this job to run again in 1 minute
      PredictionJobMonitorJob.perform_in(MONITOR_JOB_RESCHEDULE_DELAY.minute, prediction_job.id)
    end
  end
end
