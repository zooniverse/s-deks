# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::TrainingDataCsv do
  describe '#dump' do
    fixtures :contexts

    let(:workflow_id) { 4 }
    let(:exporter) { described_class.new(workflow_id) }
    let(:subject_locations) do
      [
        { 'image/jpeg': 'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }
      ]
    end
    let(:reduction_subject) do
      Subject.create({ subject_id: 1, context_id: 1, locations: subject_locations })
    end
    let(:user_reduction_attributes) do
      {
        subject_id: reduction_subject.id,
        workflow_id: workflow_id,
        labels: {
          'smooth-or-featured_smooth' => 3,
          'smooth-or-featured_featured-or-disk' => 9,
          'smooth-or-featured_artifact' => 0
        },
        unique_id: '8000_231121_468',
        raw_payload: {}
      }
    end

    before do
      UserReduction.create(user_reduction_attributes)
    end

    it 'returns a temp file' do
      expect(exporter.dump).to be_a(Tempfile)
    end

    it 'returns the csv data in the temp file' do
      expected_output = "id_str,file_loc,smooth-or-featured_smooth,smooth-or-featured_featured-or-disk,smooth-or-featured_artifact\n8000_231121_468,/test/training_images/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg,3,9,0\n"
      results = File.read(exporter.dump.path)
      expect(results).to match(expected_output)
    end

    context 'with a multi image subject' do
      let(:subject_locations) do
        [
          { 'image/jpeg': 'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' },
          { 'image/jpeg': 'https://panoptes-uploads.zooniverse.org/subject_location/fdccb1cf-0fc9-49b5-b054-62c83bccb9cd.jpeg' }
        ]
      end

      it 'returns the multi image csv data in the temp file' do
        expected_output = "id_str,file_loc,smooth-or-featured_smooth,smooth-or-featured_featured-or-disk,smooth-or-featured_artifact\n8000_231121_468,/test/training_images/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg,3,9,0\n8000_231121_468,/test/training_images/fdccb1cf-0fc9-49b5-b054-62c83bccb9cd.jpeg,3,9,0"
        results = File.read(exporter.dump.path)
        expect(results).to match(expected_output)
      end
    end
  end
end
