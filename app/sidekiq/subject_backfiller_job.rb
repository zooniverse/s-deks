# frozen_string_literal: true

class SubjectBackfillerJob
  include Sidekiq::Job

  def perform(subject_id)
    subject_to_backfill_data = Subject.find(subject_id)
    Import::SubjectLocations.new(subject_to_backfill_data).run
  end
end
