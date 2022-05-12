# frozen_string_literal: true

class Reduction < ApplicationRecord
  belongs_to :subject, optional: true

  validates :zooniverse_subject_id,
            presence: true,
            uniqueness: {
              scope: %i[workflow_id task_key],
              message: 'Reduction must be unique for the zooniverse subject, workflow and task key'
            }
end
