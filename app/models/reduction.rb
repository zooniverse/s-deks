# frozen_string_literal: true

class Reduction < ApplicationRecord
  belongs_to :subject, optional: true

  validates :zooniverse_subject_id, presence: true, uniqueness: { scope: :workflow_id, message: 'Reduction must be unique for the zooniverse subject and workflow' }
end
