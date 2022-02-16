# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :context

  validates :subject_id, :context_id, presence: true
end
