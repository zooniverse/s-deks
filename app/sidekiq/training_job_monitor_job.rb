# frozen_string_literal: true

class TrainingJobMonitorJob
  include Sidekiq::Job

  MONITOR_JOB_RESCHEDULE_DELAY = ENV.fetch('MONITOR_JOB_RESCHEDULE_DELAY', 1).to_i

  def perform(training_job_id)
    training_job = TrainingJob.find(training_job_id)

    # short circuit if we run this on a job that's already done
    return if training_job.completed?

    training_job = Batch::Training::MonitorJob.new(training_job).run

    # avoid rescheduling the job if it's failed or completed
    return if training_job.failed?

    if training_job.completed?
      # As the training job is finished- we want to run the prediction system using the newly trained model
      # so we call the prediction manifest export job to create a manifest and submit it for batch processing
      #
      # NOTE: this jobs allows us to override the subject set id
      # if we want to create a prediction manifest for a specific subject set
      # and not just the Default GZ Active Learning Loop system setup.
      PredictionManifestExportJob.perform_async
    else
      # reschedule this job to run again in 1 minute
      TrainingJobMonitorJob.perform_in(MONITOR_JOB_RESCHEDULE_DELAY.minute, training_job.id)
    end
  end
end
