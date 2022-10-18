# frozen_string_literal: true

class PredictionJob < ApplicationRecord
  validates :manifest_url, presence: true

  # state attribute has an enum of valid states
  # [:pending, :submitted, :failed, :completed]
  # these aren't enforced in a validation
  # as they are set by the create job service code
end
