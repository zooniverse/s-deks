class AddUniqueIndexToSubject < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :subjects, %i[zooniverse_subject_id context_id], unique: true, algorithm: :concurrently
  end
end
