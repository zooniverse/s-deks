# frozen_string_literal: true

class TrainingDataSyncerJob
  include Sidekiq::Job

  SYNCER_JOB_RESCHEDULE_MAX_DELAY = ENV.fetch('SYNCER_JOB_RESCHEDULE_MAX_DELAY', 3).to_i

  def perform(subject_id)
    subject = Subject.find(subject_id)
    subject.locations.each do |location|
      src_image_url = location.values.first
      Storage::TrainingDataSync.new(src_image_url).run
    end
  rescue Storage::TrainingDataSync::Failure => _e
    # this can happen with concurrent syncing jobs trying to upload at the same time
    # reschedule this job to run again in a random time
    # between 1 and SYNCER_JOB_RESCHEDULE_MAX_DELAY minutes
    delay = (1..SYNCER_JOB_RESCHEDULE_MAX_DELAY).to_a.sample
    TrainingDataSyncerJob.perform_in(delay.minute, subject_id)
  end
end
