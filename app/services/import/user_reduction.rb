# frozen_string_literal: true

module Import
  class UserReduction
    attr_accessor :payload, :label_extractor

    # allow the label extracror to be injected at run time for the specific project we import data for
    def initialize(payload, label_extractor = LabelExtractors::GalaxyZoo)
      @payload = payload.with_indifferent_access
      @label_extractor = label_extractor
    end

    def import
      # use the top level model namespace
      ::UserReduction.new(
        raw_payload: payload,
        subject_id: subject_id,
        workflow_id: workflow_id,
        labels: labels
      )
    end

    private

    def subject_id
      payload.dig('subject', 'id')
    end

    def workflow_id
      return unless for_workflow_reducible

      payload.dig('reducible', 'id')
    end

    def for_workflow_reducible
      payload.dig('reducible', 'type').casecmp?('workflow')
    end

    # use a custom label extractor (injected at run time)
    # for the different workflow data reduction payloads
    # to convert the reduced volunteer data (stats reducer)
    # key format lables to human readable string labels
    def labels
      label_extractor.extract(payload['data'])
    end
  end
end
