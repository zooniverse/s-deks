# frozen_string_literal: true

class AddAttributesToPredictionJob < ActiveRecord::Migration[7.0]
  def change
    safety_assured {
      change_table :prediction_jobs, bulk: true do |t|
        t.bigint :subject_set_id, null: false
        t.decimal :probability_threshold, null: false
        t.decimal :randomisation_factor, null: false
      end
    }
  end
end
