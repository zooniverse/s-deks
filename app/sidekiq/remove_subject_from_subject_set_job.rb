# frozen_string_literal: true

require 'panoptes/api'

class RemoveSubjectFromSubjectSetJob
  include Sidekiq::Job

  def perform(subject_id, subject_set_id)
    # as the client subject set resource doesn't offer this method
    # use the underlying client implementation to achieve it
    # longer term I should add this to the client...
    # apologies to all future selves for not doing so this time :heart:
    Panoptes::Api.client.panoptes.delete("/subject_sets/#{subject_set_id}/links/subjects/#{subject_id}")
  end
end
