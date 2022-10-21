# frozen_string_literal: true

require 'bajor/client'

module Batch
  module Prediction
    class MonitorJob
      attr_accessor :prediction_job, :bajor_client

      def initialize(prediction_job, bajor_client = Bajor::Client.new)
        @prediction_job = prediction_job
        @bajor_client = bajor_client
      end

      def run
        begin
          if (results_url = bajor_client.prediction_job_results(prediction_job.job_id))
            # TODO: longer term we will have to combine / format the results file
            # to a useful format with a json schem describing the results data
            # however let's return it for now as a csv file
            prediction_job.update!(state: :completed, results_url: results_url)
          end
        rescue Bajor::Client::PredictionJobTaskError => e
          # mark the jobs as failed and record the client error message
          prediction_job.update!(state: :failed, message: e.message)
        end
        # return the prediction job resource
        prediction_job
      end
    end
  end
end
