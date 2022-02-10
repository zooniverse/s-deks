# frozen_string_literal: true

class Subject < ApplicationRecord
  validates :subject_id, :workflow_id, :project_id, presence: true
end
