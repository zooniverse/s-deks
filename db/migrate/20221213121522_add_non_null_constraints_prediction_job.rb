# frozen_string_literal: true

class AddNonNullConstraintsPredictionJob < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_column_null :prediction_jobs, :subject_set_id, false
      change_column_null :prediction_jobs, :probability_threshold, false
      change_column_null :prediction_jobs, :randomisation_factor, false
    end
  end
end
