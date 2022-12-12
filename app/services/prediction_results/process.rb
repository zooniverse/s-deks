# frozen_string_literal: true

require 'remote_file/reader'

module PredictionResults
  class Process
    attr_accessor :prediction_job, :subject_set_id, :probability_threshold,
                  :over_threshold_subject_ids, :under_threshold_subject_ids,
                  :randomisation_factor, :prediction_data

    def initialize(prediction_job, subject_set_id, probability_threshold: 0.8, randomisation_factor: 0.1)
      @prediction_job = prediction_job
      @subject_set_id = subject_set_id
      @probability_threshold = probability_threshold
      @randomisation_factor = randomisation_factor
      @over_threshold_subject_ids = []
      @under_threshold_subject_ids = []
      @prediction_data = nil
    end

    def run
      # paritions the data by specified probability threshold
      RemoteFile::Reader.stream_to_tempfile(prediction_job.results_url) do |results_file|
        # read the prediciton json data from the tempfile
        prediction_data_results = JSON.parse(results_file.read, symbolize_names: true)
        @prediction_data = prediction_data_results[:data]
        partition_results
        move_over_threshold_subjects_to_active_set
        add_random_under_threshold_subjects_to_active_set
      end
    end

    def partition_results
    end

    def move_over_threshold_subjects_to_active_set
    end

    def add_random_under_threshold_subjects_to_active_set
    end
  end
end
