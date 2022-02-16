class CreateContexts < ActiveRecord::Migration[7.0]
  def change
    create_table :contexts do |t|
      t.bigint :workflow_id, null: false
      t.bigint :project_id, nnull: false
      t.timestamps
    end
  end
end
