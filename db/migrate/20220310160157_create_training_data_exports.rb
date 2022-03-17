# frozen_string_literal: true

class CreateTrainingDataExports < ActiveRecord::Migration[7.0]
  def change
    create_table :training_data_exports do |t|
      t.integer :state, default: 0, null: false
      t.bigint  :workflow_id, null: false
      t.text    :storage_path, null: false, default: ''
      t.timestamps
    end
  end
end
