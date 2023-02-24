# frozen_string_literal: true

require 'panoptes/api'

class RemoveSubjectFromSubjectSetJob
  include Sidekiq::Job

  def perform(subject_ids, subject_set_id, max_retries=3)
    retries ||= 1
    # format the subject ids into a comma separated string
    # which the API expects for the destroy_links action
    linked_subject_ids = Array.wrap(subject_ids).join(',')
    # as the client subject set resource doesn't offer this method
    # use the underlying client implementation to achieve it
    # longer term I should add this to the client...
    # apologies to all future selves for not doing so this time :sadpanda:
    Sync do
      Panoptes::Api.client.panoptes.delete("/subject_sets/#{subject_set_id}/links/subjects/#{linked_subject_ids}")
    rescue Panoptes::Client::ServerError => e
      # handle intermittent API errors like the following
      # e.g. {"errors"=>[{"message"=>"Attempted to update a stale object: SubjectSet."}]}
      retries += 1
      raise e if retries > max_retries

      # sleep for a random amount of time between 0 and max_retries and then retry the API client operation
      sleep(rand(max_retries))
      retry
    ensure
      Faraday.default_connection.close
    end
  end
end
