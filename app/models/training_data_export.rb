# frozen_string_literal: true

class TrainingDataExport < ApplicationRecord
  # default is pending via the migration default: 0
  enum :state, %i[pending started finished failed]

  validates :state, presence: true

  has_one_attached :file
end
