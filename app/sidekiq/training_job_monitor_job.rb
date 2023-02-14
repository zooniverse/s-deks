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
    return if training_job.failed? || training_job.completed?

    # reschedule this job to run again in 1 minute
    TrainingJobMonitorJob.perform_in(MONITOR_JOB_RESCHEDULE_DELAY.minute, training_job.id)
  end
end
