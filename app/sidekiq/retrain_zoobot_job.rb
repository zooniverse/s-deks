# frozen_string_literal: true

class RetrainZoobotJob
  include Sidekiq::Job

  RECENT_TRAINING_EXPORT_WINDOW = ENV.fetch('RECENT_TRAINING_EXPORT_WINDOW', 12).to_i

  def perform(workflow_id = nil)
    # allow the workflow_id to be optional and default a known value
    # GZ staging test project - https://caesar-staging.zooniverse.org/workflows/3598
    # GZ production project   - https://caesar.zooniverse.org/workflows/21802
    workflow_id ||= ENV.fetch('ZOOBOT_GZ_WORKFLOW_ID', 3598)

    # see if we have a recent re-usable data export instead of making one each time
    # the data should be similar and the window period is configurable
    training_data_export = find_recent_training_data_export(workflow_id)

    # if we haven't found a recent training data export then create one
    unless training_data_export
      training_data_export = TrainingDataExport.create!(
        storage_path: TrainingDataExport.storage_path(workflow_id),
        workflow_id: workflow_id
      )

      # run the export service code to create the training data export catalogue on blob storage system
      Export::TrainingData.new(training_data_export).run
    end

    # submit the export training data manifest to the batch training service
    blob_storage_manifest_path = training_data_export.storage_path_key
    Batch::Training::CreateJob.new(blob_storage_manifest_path).run

    # TODO: kick off a job monitor here to check the status of the batch training job
    # and report back to the user when the training job has completed / failed
  end

  def find_recent_training_data_export(workflow_id)
    # this query is supported by a compond unique index on
    # the [id workflow_id state] columns that results in a
    # backwards Index Scan to find the most recent finished record we have for this workflow
    recent_training_data_export = TrainingDataExport.where(workflow_id: workflow_id, state: :finished).order(id: :desc).first

    # return nil if the training data export is not recently finished with fresh data
    # this helps avoid running possible expensive data export operations
    # on job failure / re-runs with the recent window period etc
    return nil unless training_data_export_is_recent?(recent_training_data_export)

    recent_training_data_export
  end

  private

  def training_data_export_is_recent?(training_data_export)
    return false unless training_data_export

    training_data_export.created_at >= RECENT_TRAINING_EXPORT_WINDOW.hours.ago
  end
end
