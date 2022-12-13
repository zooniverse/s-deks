# frozen_string_literal: true

class AddSubjectToSubjectSetJob
  include Sidekiq::Job

  def perform(subject_id, subject_set_id)
    panoptes_client.add_subjects_to_subject_set(subject_set_id, subject_id)
  end

  private

  def panoptes_client
    @panoptes_client ||= Panoptes::Client.new(
      env: Rails.env.to_s,
      # setup via oauth applications page - https://panoptes.zooniverse.org/oauth/applications
      auth: {
        client_id: ENV.fetch('PANOPTES_OAUTH_CLIENT_ID'),
        client_secret: ENV.fetch('PANOPTES_OAUTH_CLIENT_SECRET')
      },
      # without this the owner of the oauth application needs to be have
      # collaborator rights on each project we want to modify
      params: { admin: true }
    )
  end
end