# frozen_string_literal: true

require 'csv'

module Format
  class TrainingDataCsv
    FILE_HEADERS = %w[id_str file_loc].freeze
    LABEL_HEADERS = %w[smooth-or-featured_smooth smooth-or-featured_featured-or-disk smooth-or-featured_artifact].freeze

    attr_reader :workflow_id, :temp_file

    def initialize(workflow_id)
      @workflow_id = workflow_id
      @temp_file = Tempfile.new("user_reductions_workflow_id_#{workflow_id}.csv")
    end

    def run
      csv << (FILE_HEADERS | LABEL_HEADERS)
      user_reduction_scope.find_each do |user_reduction|
        # Ensure we handle multi image subjects here
        # include 1 line per image for use in training catalogues
        user_reduction.subject.locations.each do |location|
          # each location is an object containing only 1 mimetype key and an image URL
          image_url = location.values.first
          csv << [
            user_reduction.unique_id,
            Zoobot.container_image_path(image_url),
            user_reduction.labels[LABEL_HEADERS[0]],
            user_reduction.labels[LABEL_HEADERS[1]],
            user_reduction.labels[LABEL_HEADERS[2]]
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
      UserReduction.where(workflow_id: workflow_id)
    end

    # avoid N+1 lookups here, preload the subject as required
    def user_reduction_scope
      UserReduction.where(workflow_id: workflow_id).preload(:subject)
    end
  end
end
