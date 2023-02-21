# frozen_string_literal: true

class AddSubjectToSubjectSetJob
  include Sidekiq::Job

  def perform(subject_id, subject_set_id, max_retries=3)
    retries ||= 1
    Panoptes::Api.client.add_subjects_to_subject_set(subject_set_id, [subject_id])
  rescue Panoptes::Client::ServerError => e
    # handle intermittent API errors like the following
    # e.g. {"errors"=>[{"message"=>"Attempted to update a stale object: SubjectSet."}]}
    retries += 1
    raise e if retries > max_retries

    # sleep for a random amount of time between 0 and max_retries and then retry the API client operation
    sleep(rand(max_retries))
    retry
  end
end
