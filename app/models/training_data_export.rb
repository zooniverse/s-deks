# frozen_string_literal: true

class TrainingDataExport < ApplicationRecord
  # default is started via the migration default: 0
  enum :state, %i[started finished failed]

  validates :state, :workflow_id, presence: true

  has_one_attached :file

  def storage_path_key
    storage_path.delete_prefix("/#{Rails.env}")
  end

  def storage_path_file_name
    File.basename(storage_path)
  end
end
