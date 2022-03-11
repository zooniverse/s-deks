# frozen_string_literal: true
require 'csv'

module Export
  class TrainingDataCsv
    HEADERS = %w[id_str file_loc smooth-or-featured_smooth smooth-or-featured_featured-or-disk smooth-or-featured_artifact]
    attr_reader :workflow_id, :temp_file

    def initialize(workflow_id)
      @workflow_id = workflow_id
      @temp_file = Tempfile.new("user_reductions_workflow_id_#{workflow_id}.csv")
    end

    def dump
      csv << HEADERS
      UserReduction.where(workflow_id: workflow_id).find_each do |user_reduction|
        # long term we may have to think about multi image subjects here
        # and spit out 1 row for each image frame
        # so perhaps make the `zoobot_container_path` an array for easy addition of new frames
        # and we loop here to ensure we capture each image frame
        # with the reduction data
        csv << [
          user_reduction.unique_id,
          # TODO: ensure this method is available on the user_reduction model
          #   the data comes from the subject URL that is copied into an expected
          #   storage container path prefix and filename of the source URL from the subject location
          user_reduction.zoobot_container_path, # the path in the zoobot storage container for this file
          user_reduction.labels['smooth-or-featured_smooth'],
          user_reduction.labels['smooth-or-featured_featured-or-disk'],
          user_reduction.labels['smooth-or-featured_artifact']
        ]
      end
      temp_file.rewind
      temp_file
    end

    # csv_dump << formatter.headers if formatter.headers

    private

    def csv
      @csv ||= CSV.new(temp_file)
    end

    def dump_scope
      UserReduction.where(workflow_id: workflow_id)
    end
  end
end
