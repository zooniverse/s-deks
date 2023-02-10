# frozen_string_literal: true

require 'bajor/client'

module Batch
  module Training
    class MonitorJob
      attr_accessor :training_job, :bajor_client

      def initialize(training_job, bajor_client = Bajor::Client.new)
        @training_job = training_job
        @bajor_client = bajor_client
      end

      def run
        begin
          if (results_url = bajor_client.training_job_results(training_job.job_id))
            training_job.update!(state: :completed, results_url: results_url)
          end
        rescue Bajor::Client::TrainingJobTaskError => e
          # mark the jobs as failed and record the client error message
          training_job.update!(state: :failed, message: e.message)
        end
        # return the training job resource
        training_job
      end
    end
  end
end
