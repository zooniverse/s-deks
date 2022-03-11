# frozen_string_literal: true

class TrainingDataExport < ApplicationRecord
  # default is pending via the migration default: 0
  enum :state, %i[pending started finished failed]

  # has_one_attached :file
end
