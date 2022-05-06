class AddUniqIndexWithTaskKeyToReductions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :reductions, %i[workflow_id subject_id task_key], unique: true, algorithm: :concurrently
    remove_index :reductions, %i[workflow_id subject_id]
  end
end
