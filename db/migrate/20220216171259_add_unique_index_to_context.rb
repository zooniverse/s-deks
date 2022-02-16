class AddUniqueIndexToContext < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :contexts, %i[workflow_id project_id], unique: true, algorithm: :concurrently
  end
end
