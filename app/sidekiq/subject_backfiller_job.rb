# frozen_string_literal: true

class SubjectBackfillerJob
  include Sidekiq::Job

  def perform(subject_id)
    subject = Subject.find(subject_id)
    Import::SubjectLocations.new(subject).run

    # now we have the URL's backfilled we can sync
    # the training images to the storage container
    TrainingDataSyncerJob.perform_async(subject.id)
  end
end
