# frozen_string_literal: true

require 'bajor/client'

module Batch
  module Training
    class CreateJob
      attr_accessor :manifest_path, :bajor_client

      def initialize(manifest_path, bajor_client = Bajor::Client.new)
        @manifest_path = manifest_path
        @bajor_client = bajor_client
      end

      def run
        bajor_client.create_training_job(manifest_path)
      end
    end
  end
end
