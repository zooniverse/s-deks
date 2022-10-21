# frozen_string_literal: true

class PredictionJob < ApplicationRecord
  validates :manifest_url, presence: true
  validates :state, inclusion: { in: %w[pending submitted failed completed], allow_nil: true }
end
