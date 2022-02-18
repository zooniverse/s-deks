# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :context

  has_many :user_reductions, dependent: :restrict_with_exception

  validates :subject_id, presence: true, uniqueness: { scope: :context_id, message: 'Subject must be unique for the context' }
end
