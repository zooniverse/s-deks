# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::TrainingData do
  describe '#run' do
    let(:export_key_prefix) { Time.now.iso8601 }
    let(:export_service_instance) { described_class.new(1, export_key_prefix: export_key_prefix) }
    let(:formatter_double) { instance_double(Format::TrainingDataCsv) }
    let(:training_data_model) { TrainingDataExport.new }
    let(:temp_export_file) { Tempfile.new }
    let(:blob_key) { "training_catalogues/#{export_key_prefix}-training-catalogue.csv" }
    let(:active_storage_proxy) { training_data_model.file }

    before do
      allow(TrainingDataExport).to receive(:create).and_return(training_data_model)
      allow(formatter_double).to receive(:run).and_return(temp_export_file)
      allow(Format::TrainingDataCsv).to receive(:new).and_return(formatter_double)
      allow(active_storage_proxy).to receive(:attach)
      allow(active_storage_proxy).to receive(:attached?).and_return(true)
    end

    it 'does not raise unexpected errors' do
      expect { export_service_instance.run }.not_to raise_error
    end

    it 'creates the TrainingDataExport model' do
      export_service_instance.run
      expect(TrainingDataExport).to have_received(:create).once
    end

    it 'calls the formatter service' do
      export_service_instance.run
      expect(formatter_double).to have_received(:run).once
    end

    it 'uploads the export file at a known storage key' do
      attach_params = { key: blob_key, io: temp_export_file, filename: blob_key }
      export_service_instance.run
      expect(active_storage_proxy).to have_received(:attach).with(attach_params)
    end

    it 'marks the export model as finished!' do
      export_service_instance.run
      expect(training_data_model.finished?).to be(true)
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
