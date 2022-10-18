class AddBatchJobModel < ActiveRecord::Migration[7.0]
  def change
    create_table :prediction_jobs do |t|
      t.text :service_job_url
      t.text :manifest_url, null: false
      t.timestamps
    end
  end
end
