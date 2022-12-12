# frozen_string_literal: true

class AddSubjectToSubjectSetJob
  include Sidekiq::Job

  def perform(subject_id, subject_set_id)
    panoptes_client.add_subjects_to_subject_set(subject_set_id, subject_id)
  end

  private

  def panoptes_client
    # TODO: this will need auth setup
    @panoptes_client ||= Panoptes::Client.new(env: Rails.env.to_s)
  end
end