class Context < ApplicationRecord
  has_many :subjects, dependent: :restrict_with_exception

  validates :workflow_id, uniqueness: { scope: :project_id, message: 'Workflow and project must be unique' }
end
