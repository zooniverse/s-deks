# frozen_string_literal: true

class TrainingJob < ApplicationRecord
  validates :manifest_url, presence: true
  validates :state, inclusion: { in: %w[pending submitted failed completed], allow_nil: true }

  def completed?
    state == 'completed'
  end

  def submitted?
    state == 'submitted'
  end

  def failed?
    state == 'failed'
  end

  def job_id
    File.basename(service_job_url)
  end

  def manifest_path
    # in the training batch processing system the manifest path is relative to the training container
    # so we need to remove the training container prefix here when we submit the batch job
    manifest_url_path = URI.parse(manifest_url.chomp).path
    manifest_url_path.delete_prefix("/#{Zoobot::Storage.container_name}")
  end
end
