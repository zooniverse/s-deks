class AddPredictionJobModel < ActiveRecord::Migration[7.0]
  def change
    create_table :prediction_jobs do |t|
      t.text   :service_job_url, default: ''
      t.text   :manifest_url, null: false
      t.string :state, null: false
      t.text   :message, null: false, default: ''
      t.timestamps
    end
  end
end
