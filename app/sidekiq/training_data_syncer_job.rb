# frozen_string_literal: true

class TrainingDataSyncerJob
  include Sidekiq::Job

  def perform(subject_id)
    subject = Subject.find(subject_id)
    subject.locations.each do |location|
      src_image_url = location.values.first
      Storage::TrainingDataSync.new(src_image_url).run
    end
  end
end
