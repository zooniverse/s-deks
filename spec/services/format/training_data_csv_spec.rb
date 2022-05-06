# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Format::TrainingDataCsv do
  describe '#run' do
    fixtures :contexts

    let(:workflow_id) { 4 }
    let(:formatter) { described_class.new(workflow_id) }
    let(:subject_locations) do
      [
        { 'image/jpeg': 'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }
      ]
    end
    let(:reduction_subject) do
      Subject.create(zooniverse_subject_id: 1, context_id: 1, locations: subject_locations)
    end
    let(:reduction_attributes) do
      {
        subject_id: reduction_subject.id,
        zooniverse_subject_id: reduction_subject.zooniverse_subject_id,
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
    let(:export_file) { formatter.run }

    before do
      Reduction.create(reduction_attributes)
    end

    it 'returns a temp file' do
      expect(formatter.run).to be_a(Tempfile)
    end

    it 'returns the csv data in the temp file' do
      expected_output = "id_str,file_loc,smooth-or-featured_smooth,smooth-or-featured_featured-or-disk,smooth-or-featured_artifact\n8000_231121_468,/test/training_images/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg,3,9,0\n"
      results = File.read(export_file.path)
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
        results = File.read(export_file.path)
        expect(results).to match(expected_output)
      end
    end

    context 'with no subject locations - pending backfilling' do
      let(:subject_locations) { [] }

      it 'raises an error' do
        expect {
          export_file
        }.to raise_error(Format::TrainingDataCsv::MissingLocationData, "For subject id: #{reduction_subject.id}")
      end
    end
  end
end
