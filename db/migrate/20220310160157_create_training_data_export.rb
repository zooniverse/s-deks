# frozen_string_literal: true

class CreateTrainingDataExport < ActiveRecord::Migration[7.0]
  def change
    create_table :training_data_export do |t|
      t.integer :state, default: 0, null: false
      t.timestamps
    end
  end
end
