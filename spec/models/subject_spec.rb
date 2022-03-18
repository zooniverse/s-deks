# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  fixtures :contexts

  let(:locations) do
    [{ 'image/jpeg': 'https://panoptes-uploads.zooniverse.org/subject_location/2f2490b4-65c1-4dca-ba25-c44128aa7a39.jpeg' }]
  end
  let(:attributes) do
    { zooniverse_subject_id: 1, context_id: 1, locations: locations }
  end
  let(:model) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(model).to be_valid
  end

  it 'is invalid without a zooniverse_subject_id' do
    model.zooniverse_subject_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid without a context_id' do
    model.context_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid for duplicate subjects in the same context' do
    model.save!
    dup = described_class.new(attributes)
    dup.valid?
    expect(dup.errors[:zooniverse_subject_id]).to include('Subject must be unique for the context')
  end

  describe '.context' do
    it 'correctly links the association' do
      expect(model.context).to be_valid
    end
  end

  describe '.user_reductions' do
    let(:user_reduction) do
      UserReduction.create(
        {
          zooniverse_subject_id: model.zooniverse_subject_id,
          subject_id: model.id,
          workflow_id: 4,
          labels: { 'smooth-or-featured_smooth' => 1, 'smooth-or-featured_featured-or-disk' => 3 },
          unique_id: '8000_231121_468',
          raw_payload: {}
        }
      )
    end

    before do
      model.save!
      user_reduction
    end

    it 'correctly links the association' do
      expect(model.user_reductions).to match_array(user_reduction)
    end

    it 'raises an error when destroying' do
      expect { model.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError, 'Cannot delete record because of dependent user_reductions')
    end
  end

  describe '.predictions' do
    let(:prediction) do
      Prediction.create({ subject_id: model.id, image_url: 'url', results: {} })
    end

    before do
      model.save!
      prediction
    end

    it 'correctly links the association' do
      expect(model.predictions).to match_array(prediction)
    end

    it 'raises an error when destroying' do
      expect { model.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError, 'Cannot delete record because of dependent predictions')
    end

    it 'allows for multi image subject predictions' do
      frame_2_prediction = Prediction.create({ subject_id: model.id, image_url: 'url_2', results: {} })
      expect(model.predictions).to match_array([frame_2_prediction, prediction])
    end

    it 'allows a subject to have predictions for the same image path' do
      latest_image_prediction = Prediction.create({ subject_id: model.id, image_url: 'url', results: {} })
      # note: this also tests the association ordering clause to ensure we load the latest ones first
      expect(model.predictions).to match([latest_image_prediction, prediction])
    end
  end
end
