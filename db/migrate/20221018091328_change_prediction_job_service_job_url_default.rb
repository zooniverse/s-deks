class ChangePredictionJobServiceJobUrlDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :prediction_jobs, :service_job_url, from: nil, to: ''
  end
end
