class CreateTrainingJobModel < ActiveRecord::Migration[7.0]
  def change
    create_table :training_jobs do |t|
      t.text   :service_job_url, default: ''
      t.text   :manifest_url, null: false
      t.text   :results_url, null: false, default: ''
      t.string :state, null: false
      t.bigint :workflow_id, null: false
      t.text   :message, null: false, default: ''
      t.timestamps
    end
  end
end
