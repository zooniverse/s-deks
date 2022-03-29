# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::TrainingData do
  describe '#run' do
    let(:workflow_id) { 10 }
    let(:file_time) { Time.now.iso8601 }
    let(:storage_path) { "#{Zoobot.storage_path_key(workflow_id)}-#{file_time}.csv" }
    let(:storage_path_file_name) { "workflow-#{workflow_id}-#{file_time}.csv" }
    let(:storage_path_key) { "/training_catalogues/#{storage_path_file_name}" }

    let(:training_data_model) { TrainingDataExport.new(workflow_id: workflow_id, storage_path: storage_path) }
    let(:export_service_instance) { described_class.new(training_data_model) }
    let(:formatter_double) { instance_double(Format::TrainingDataCsv) }

    let(:temp_export_file) { Tempfile.new }
    let(:active_storage_proxy) { training_data_model.file }

    before do
      allow(TrainingDataExport).to receive(:create).and_return(training_data_model)
      allow(formatter_double).to receive(:run).and_return(temp_export_file)
      allow(Format::TrainingDataCsv).to receive(:new).and_return(formatter_double)
      allow(active_storage_proxy).to receive(:attach)
      allow(active_storage_proxy).to receive(:attached?).and_return(true)
    end

    it 'does not raise unexpected errors', :focus do
      expect { export_service_instance.run }.not_to raise_error
    end

    it 'calls the formatter service' do
      export_service_instance.run
      expect(formatter_double).to have_received(:run).once
    end

    it 'uploads the export file at a known storage key' do
      attach_params = { key: storage_path_key, io: temp_export_file, filename: storage_path_file_name }
      export_service_instance.run
      expect(active_storage_proxy).to have_received(:attach).with(attach_params)
    end

    it 'marks the export model as finished' do
      expect { export_service_instance.run }.to change(training_data_model, :finished?).from(false).to(true)
    end

    it 'records the storage path on the export model' do
      export_service_instance.run
      expect(training_data_model.storage_path).to match(storage_path)
    end

    context 'with an failed remote file upload' do
      before do
        allow(active_storage_proxy).to receive(:attached?).and_return(false)
      end

      it 'marks the export model as failed!' do
        export_service_instance.run
        expect(training_data_model.failed?).to be(true)
      end
    end
  end
end
