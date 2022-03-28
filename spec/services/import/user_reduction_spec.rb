# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::UserReduction do
  fixtures :contexts

  let(:context) { Context.first }
  let(:zooniverse_subject_id) { 999 }
  let(:raw_payload) do
    ActionController::Parameters.new(
      {
        'id' => 4,
        'reducible' => {
          'id' => context.workflow_id,
          'type' => 'Workflow'
        },
        'data' => {
          '0' => 3, # smooth
          '1' => 9, # features or disk
          '2' => 0  # star or artifact
        },
        subject: {
          id: zooniverse_subject_id,
          'metadata' => { '#name' => '8000_231121_468' },
          'created_at' => '2021-08-06T11:08:53.918Z',
          'updated_at' => '2021-08-06T11:08:53.918Z'
        },
        'created_at' => '2021-08-06T11:08:54.000Z',
        'updated_at' => '2021-08-06T11:08:54.000Z'
      }
    )
  end

  describe '.run' do
    let(:expected_labels) do
      {
        'smooth-or-featured_smooth' => 3,
        'smooth-or-featured_featured-or-disk' => 9,
        'smooth-or-featured_artifact' => 0
      }
    end
    let(:label_extractor) { LabelExtractors::GalaxyZoo.new(raw_payload['data']) }
    let(:user_reduction_model) { described_class.new(raw_payload).run }

    it 'converts the raw reduction payload to a valid UserReduction model' do
      expect(user_reduction_model).to be_valid
    end

    it 'extracts the labels correctly' do
      expect(user_reduction_model.labels).to match(expected_labels)
    end

    it 'extracts the name correctly for staging env' do
      staging_payload = raw_payload.dup
      staging_payload_metadata = raw_payload[:subject]['metadata'].dup
      staging_payload_metadata['!SDSS_ID'] = '1237663785278570672'
      staging_payload[:subject]['metadata'] = staging_payload_metadata.except('#name')
      user_reduction_model_staging = described_class.new(staging_payload).run
      expect(user_reduction_model_staging.unique_id).to match('1237663785278570672')
    end

    it 'creates a placeholder backfilling subject' do
      expect { user_reduction_model }.to change(Subject, :count).from(0).to(1)
    end

    it 'correctly sets up the placeholder backfilling subject' do
      expected_subject_attributes = { 'zooniverse_subject_id' => zooniverse_subject_id, 'context_id' => context.id }
      expect(user_reduction_model.subject.attributes).to include(expected_subject_attributes)
    end

    it 'correctly links existing known subjects' do
      subject = Subject.create(zooniverse_subject_id: zooniverse_subject_id, context_id: context.id)
      expect(user_reduction_model.subject_id).to match(subject.id)
    end

    it 'raises with an invalid payload' do
      expect {
        described_class.new({}).run
      }.to raise_error(Import::UserReduction::InvalidPayload, 'missing workflow and/or subject_id')
    end
  end
end
