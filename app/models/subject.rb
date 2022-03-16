# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :context

  has_many :user_reductions, dependent: :restrict_with_exception

  has_many :predictions, -> { order(id: :desc) }, inverse_of: :subject, dependent: :restrict_with_exception

  validates :zooniverse_subject_id, presence: true, uniqueness: { scope: :context_id, message: 'Subject must be unique for the context' }
end
