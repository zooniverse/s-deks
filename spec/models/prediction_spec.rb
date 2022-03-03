# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Prediction, type: :model, focus: true do
  let(:image_url) do
    'https://panoptes-uploads.zooniverse.org/subject_location/11f98201-1c3f-44d5-965b-e00373daeb18.jpeg'
  end
  let(:results) do
    { 'id_str' => 'path', 'smooth_pred' => '[1., 0.9]', 'bar_pred' => '[0.3, 0.24]' }
  end
  let(:attributes) do
    { subject_id: 1, image_url: image_url, results: results }
  end
  let(:model) { described_class.new(attributes) }

  it 'creates a valid model' do
    expect(model).to be_valid
  end

  it 'is invalid without a subject_id' do
    model.subject_id = nil
    expect(model).to be_invalid
  end

  it 'is invalid without an image_url' do
    model.image_url = nil
    expect(model).to be_invalid
  end

  it 'is valid with a user_id' do
    model.user_id = 1
    expect(model).to be_valid
  end

  it 'is valid with an agent_identifier' do
    model.agent_identifier = 'zoobot_v1'
    expect(model).to be_valid
  end
end
