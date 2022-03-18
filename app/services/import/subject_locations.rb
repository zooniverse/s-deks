# frozen_string_literal: true

module Import
  class SubjectLocations
    class ApiNotFound < StandardError; end

    attr_accessor :subject

    def initialize(subject)
      @subject = subject
    end

    def run
      return subject if subject.locations.present?

      api_response = panoptes_client.subject(subject.zooniverse_subject_id)
      # add the API locations data to the existing subject
      # note response is not an indifferent access hash - response keys are always strings
      subject.locations = api_response['locations']
      subject.save!
      subject
    rescue Panoptes::Client::ResourceNotFound => _e
      raise ApiNotFound, "Can't find API subject with id: #{subject.zooniverse_subject_id}"
    end

    private

    def panoptes_client
      # Assumption: all the subject data should be located in public projects (no auth needed)
      # env: switches the API endpoint (default is staging)
      @panoptes_client ||= Panoptes::Client.new(env: Rails.env.to_s)
    end
  end
end
