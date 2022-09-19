# frozen_string_literal: true

module Training
  class Zoobot
    attr_accessor :manifest_path, :bajor_client

    def initialize(manifest_path, bajor_client = Bajor::Client.new)
      @manifest_path = manifest_path
      @bajor_client = bajor_client
    end

    def run
      # store the batch job id to check the job status later
      batch_job_id = bajor_client.train(manifest_path)
    end
  end
end
