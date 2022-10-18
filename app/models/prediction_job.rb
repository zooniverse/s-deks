# frozen_string_literal: true

class PredictionJob < ApplicationRecord
  validates :manifest_url, presence: true
end
