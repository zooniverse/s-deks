# frozen_string_literal: true

class AddAttributesToPredictionJob < ActiveRecord::Migration[7.0]
  def change
    add_column :prediction_jobs, :subject_set_id, :bigint
    add_column :prediction_jobs, :probability_threshold, :float
    add_column :prediction_jobs, :randomisation_factor, :float
  end
end
