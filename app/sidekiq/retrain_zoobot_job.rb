# frozen_string_literal: true

class RetrainZoobotJob
  include Sidekiq::Job

  def perform(workflow_id = nil)
    # allow the workflow_id to be optional and default a known value
    # GZ staging test project - https://caesar-staging.zooniverse.org/workflows/3598
    #
    # TODO: change this to the production workflow id when it's setup
    workflow_id ||= ENV.fetch('ZOOBOT_GZ_WORKFLOW_ID', 3598)

    # create the training data export resource
    training_data_export = TrainingDataExport.create!(
      storage_path: TrainingDataExport.storage_path(workflow_id),
      workflow_id: workflow_id
    )

    # run the export service code to create the training data export catalogue on blob storage system
    Export::TrainingData.new(training_data_export).run

    # submit the export training data manifest to the batch training service
    blob_storage_manifest_path = training_data_export.storage_path_key
    Batch::Training::CreateJob.new(blob_storage_manifest_path).run

    # TODO: kick off a job monitor here to check the status of the batch training job
    # and report back to the user when the training job has completed / failed
  end
end
