# frozen_string_literal: true

class AddSubjectToSubjectSetJob
  include Sidekiq::Job

  def perform(subject_id, subject_set_id)
    Panoptes::Api.client.add_subjects_to_subject_set(subject_set_id, [subject_id])
  end
end
