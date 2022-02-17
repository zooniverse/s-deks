# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :context

  validates :subject_id, presence: true, uniqueness: { scope: :context_id, message: 'Subject must be unique for the context' }
end
