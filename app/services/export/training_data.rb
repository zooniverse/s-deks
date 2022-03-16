# frozen_string_literal: true

module Export
  class TrainingData
    CONTAINER_PATH_PREFIX = 'training_catalogues'

    attr_reader :workflow_id, :export_key_prefix

    def initialize(workflow_id, export_key_prefix: Time.now.iso8601)
      @workflow_id = workflow_id
      @export_key_prefix = export_key_prefix
    end

    def run
      # 1. Create the TrainingDataExport model and
      training_data_export = TrainingDataExport.create

      # 2. create the formatted csv file export IO object
      csv_export_file = Format::TrainingDataCsv.new(workflow_id).run

      # 3. upload the export file via active storage
      # ensure we specify a known key here so we know the location on contianer storage
      # vs a rails generated key id
      training_data_export.file.attach(key: blob_key, io: csv_export_file, filename: blob_key)

      # 4. finally mark the export model state change
      if training_data_export.file.attached?
        training_data_export.finished!
      else
        training_data_export.failed!
      end
    end

    private

    def blob_key
      "#{CONTAINER_PATH_PREFIX}/#{export_key_prefix}-training-catalogue.csv"
    end
  end
end
