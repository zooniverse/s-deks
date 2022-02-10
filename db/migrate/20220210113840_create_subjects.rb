class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.bigint :subject_id
      t.bigint :workflow_id
      t.bigint :project_id
      t.jsonb   :metadata
      t.timestamps
    end
  end
end
