# frozen_string_literal: true

require 'remote_file/reader'

module PredictionResults
  class Process
    attr_accessor :results_url, :subject_set_id, :probability_threshold,
                  :over_threshold_subject_ids, :under_threshold_subject_ids,
                  :randomisation_factor, :prediction_data

    def initialize(results_url:, subject_set_id:, probability_threshold: 0.8, randomisation_factor: 0.1)
      @results_url = results_url
      @subject_set_id = subject_set_id
      @probability_threshold = probability_threshold
      @randomisation_factor = randomisation_factor
      @over_threshold_subject_ids = []
      @under_threshold_subject_ids = []
      @prediction_data = nil
    end

    def run
      # paritions the data by specified probability threshold
      RemoteFile::Reader.stream_to_tempfile(results_url) do |results_file|
        # read the prediciton json data from the tempfile
        prediction_data_results = JSON.parse(results_file.read)
        @prediction_data = prediction_data_results['data']
        partition_results
        move_over_threshold_subjects_to_active_set
        remove_under_threshold_subjects_from_active_set
        add_random_under_threshold_subjects_to_active_set
      end
    end

    def partition_results
      prediction_data.each do |subject_id, probability_values|
        # data schema format is published in the file
        # and https://github.com/zooniverse/bajor/blob/main/azure/batch/scripts/predict_on_catalog.py
        # the first value is the probability we partition on
        probability = probability_values[0]
        @over_threshold_subject_ids << subject_id if probability >= probability_threshold
        @under_threshold_subject_ids << subject_id if probability < probability_threshold
      end
    end

    def move_over_threshold_subjects_to_active_set
      bulk_job_args = over_threshold_subject_ids.map { |subject_id| [subject_id, subject_set_id] }
      AddSubjectToSubjectSetJob.perform_bulk(bulk_job_args)
    end

    def remove_under_threshold_subjects_from_active_set
      bulk_job_args = under_threshold_subject_ids.map { |subject_id| [subject_id, subject_set_id] }
      RemoveSubjectFromSubjectSetJob.perform_bulk(bulk_job_args)
    end

    def add_random_under_threshold_subjects_to_active_set
      # don't skew the prediction results by adding too many under threshold images
      # ensure we only use apply the randomisation factor to the count of over threshold subject ids
      # i.e. 10% of the number of over threshold subject ids
      num_random_subject_ids_to_sample = (over_threshold_subject_ids.count * randomisation_factor).to_i
      random_under_threshold_subject_ids = under_threshold_subject_ids.sample(num_random_subject_ids_to_sample)
      bulk_job_args = random_under_threshold_subject_ids.map { |subject_id| [subject_id, subject_set_id] }
      AddSubjectToSubjectSetJob.perform_bulk(bulk_job_args)
    end
  end
end
