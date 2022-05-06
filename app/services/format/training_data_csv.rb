# frozen_string_literal: true

require 'csv'

module Format
  class TrainingDataCsv
    class MissingLocationData < StandardError; end

    FILE_HEADERS = %w[id_str file_loc].freeze
    LABEL_HEADERS = %w[smooth-or-featured_smooth smooth-or-featured_featured-or-disk smooth-or-featured_artifact].freeze

    attr_reader :workflow_id, :temp_file

    def initialize(workflow_id)
      @workflow_id = workflow_id
      @temp_file = Tempfile.new("reductions_workflow_id_#{workflow_id}.csv")
    end

    def run
      csv << (FILE_HEADERS | LABEL_HEADERS)
      reduction_scope.find_each do |reduction|
        reduced_subject = reduction.subject
        # if location subject data is available
        # raise short term so we understand frequent / how this happens
        # and long term maybe move to skipping?
        raise MissingLocationData, "For subject id: #{reduced_subject.id}" if reduced_subject.locations.blank?

        # Ensure we handle multi image subjects here
        # include 1 line per image for use in training catalogues
        reduced_subject.locations.each do |location|
          # each location is an object containing only 1 mimetype key and an image URL
          image_url = location.values.first
          csv << [
            reduction.unique_id,
            Zoobot.container_image_path(image_url),
            reduction.labels[LABEL_HEADERS[0]],
            reduction.labels[LABEL_HEADERS[1]],
            reduction.labels[LABEL_HEADERS[2]]
          ]
        end
      end
      temp_file.rewind
      temp_file
    end

    private

    def csv
      @csv ||= CSV.new(temp_file)
    end

    def dump_scope
      Reduction.where(workflow_id: workflow_id)
    end

    # avoid N+1 lookups here, preload the subject as required
    def reduction_scope
      Reduction.where(workflow_id: workflow_id).preload(:subject)
    end
  end
end
