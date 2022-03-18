# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::SubjectLocations do
  fixtures :contexts

  let(:context) { Context.first }
  let(:zooniverse_subject_id) { 931 }
  let(:existing_subject) do
    Subject.create(zooniverse_subject_id: zooniverse_subject_id, context_id: context.id)
  end
  let(:subject_import_service) do
    described_class.new(existing_subject)
  end
  let(:panoptes_client_double) { instance_double(Panoptes::Client) }
  let(:location_data) do
    [
      { 'image/jpeg' => 'https://panoptes-uploads-staging.zooniverse.org/subject_location/7fc8724b-84de-45e7-9ce1-beab33c65323.jpeg' }
    ]
  end
  let(:fake_subject_api_response) do
    # truncated response object - only currently interested in locations data
    {
      'id' => '37182',
      'locations' => location_data
    }
  end

  before do
    allow(panoptes_client_double).to receive(:subject).with(zooniverse_subject_id).and_return(fake_subject_api_response)
    allow(Panoptes::Client).to receive(:new).and_return(panoptes_client_double)
    existing_subject
  end

  describe '.run' do
    it 'uses the api client to fetch subject data' do
      subject_import_service.run
      expect(panoptes_client_double).to have_received(:subject).with(zooniverse_subject_id)
    end

    it 'stores the locations data from the API' do
      subject = subject_import_service.run
      expect(subject.locations).to match_array(location_data)
    end

    it 'skips subjects that already have locations' do
      # long term may want to look at upserts here
      # but short term the subject data should be static
      existing_subject.locations = location_data
      expect { subject_import_service.run }.not_to change(existing_subject, :locations)
    end

    context 'with an unknown API subject' do
      let(:unknown_api_subject) do
        Subject.create(zooniverse_subject_id: 0, context_id: context.id)
      end
      let(:subject_import_service) { described_class.new(unknown_api_subject) }

      it 'raises an UnknownApiSubject error' do
        allow(panoptes_client_double).to receive(:subject).with(0).and_raise(Panoptes::Client::ResourceNotFound)
        expect { subject_import_service.run }.to raise_error(Import::SubjectLocations::ApiNotFound, "Can't find API subject with id: 0")
      end
    end
  end
end
