# frozen_string_literal: true

class UserReduction < ApplicationRecord
  belongs_to :subject, optional: true

  validates :subject_id, presence: true, uniqueness: { scope: :workflow_id, message: 'UserReduction must be unique for the subject and workflow' }
end
