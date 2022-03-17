# frozen_string_literal: true

class TrainingDataExporterJob
  include Sidekiq::Job

  def perform(training_data_export_id)
    training_data_export = TrainingDataExport.find(training_data_export_id)
    Export::TrainingData.new(training_data_export).run
  end
end
