# frozen_string_literal: true

class AddResultsUrlToPredictionJob < ActiveRecord::Migration[7.0]
  def change
    add_column :prediction_jobs, :results_url, :text, null: false, default: ''
  end
end
