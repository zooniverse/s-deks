class AddIndexToTrainingDataExportModel < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :training_data_exports, %i[id workflow_id state], unique: true, algorithm: :concurrently
  end
end
