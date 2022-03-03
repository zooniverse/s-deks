# frozen_string_literal: true

class Prediction < ApplicationRecord
  belongs_to :subject, optional: true

  validates :subject_id, presence: true

  # validates :image_url, presence: true
end
