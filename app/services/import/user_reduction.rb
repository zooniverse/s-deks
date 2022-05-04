# frozen_string_literal: true

module Import
  class UserReduction
    class InvalidPayload < StandardError; end

    attr_accessor :payload, :label_extractor

    def initialize(payload, label_extractor)
      @payload = payload
      # label extractor injected at run time for the specific project we import data for
      @label_extractor = label_extractor
    end

    def run
      validate_payload

      # compose the Import::Subject service to find or create the subject
      subject = Import::Subject.new(zooniverse_subject_id, context).run

      # TODO:
      # 1. add task_key to Reduction model - allow us to identify which extracted payloads map to the tasks
      # 2. switch to unique index on subject_id, workflow_id, task_key
      # 3. add upsert vs create! (alternatively find or create!)
      #
      # ?? how to handle different reduction payloads for different tasks
      # e.g. task1 needs a Reduction saved and so does task 2
      # but both have different labels and payloads
      # unique records via subject_id, workflow_id, task_key
      # and then upserts on these key combos...

      # use the top level model namespace
      #
      # TODO switch to an upsert here to avoid create errors (on more classification post retirement)
      ::UserReduction.create!(
        raw_payload: payload,
        subject_id: subject.id,
        zooniverse_subject_id: zooniverse_subject_id,
        workflow_id: workflow_id,
        labels: labels,
        unique_id: unique_id
      )
    end

    private

    def validate_payload
      return if workflow_id && zooniverse_subject_id

      raise InvalidPayload, 'missing workflow and/or subject_id'
    end

    def context
      Context.find_by(workflow_id: workflow_id)
    end

    def zooniverse_subject_id
      payload.dig('subject', 'id')
    end

    def workflow_id
      return unless for_workflow_reducible

      payload.dig('reducible', 'id')
    end

    def for_workflow_reducible
      payload.dig('reducible', 'type')&.casecmp?('workflow')
    end

    def unique_id
      unique_id = payload.dig('subject', 'metadata', '#name')
      return unique_id if unique_id

      # staging has older data with different subject metadata - fallback to handling this special env case
      payload.dig('subject', 'metadata', '!SDSS_ID') if Rails.env.staging? || Rails.env.test?
    end

    # use a custom label extractor (injected at run time)
    # for the different workflow data reduction payloads
    # to convert the reduced volunteer data (stats reducer)
    # key format lables to human readable string labels
    def labels
      return unless payload['data']

      label_extractor.extract(payload['data'])
    end
  end
end
