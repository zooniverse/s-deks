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
    URI.parse(manifest_url.chomp).path
  end
end
