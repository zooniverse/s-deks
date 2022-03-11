# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::TrainingDataCsv do
  describe '#dump' do
    let(:workflow_id) { 4 }
    let(:exporter) { described_class.new(workflow_id) }

    before do
      UserReduction.create(
        {
          subject_id: 1,
          workflow_id: workflow_id,
          labels: {
            'smooth-or-featured_smooth' => 3,
            'smooth-or-featured_featured-or-disk' => 9,
            'smooth-or-featured_artifact' => 0
          },
          unique_id: '8000_231121_468',
          raw_payload: {}
        }
      )
    end

    it 'returns a temp file' do
      expect(exporter.dump).to be_a(Tempfile)
    end

    it 'returns the csv data in the temp file' do
      expected_output = "id_str,file_loc,smooth-or-featured_smooth,smooth-or-featured_featured-or-disk,smooth-or-featured_artifact\n8000_231121_468,\"\",3,9,0\n"
      results = File.open(exporter.dump.path, 'rb') { |f| f.read }
      expect(results).to match(expected_output)
    end
  end
end
