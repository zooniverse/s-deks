# frozen_string_literal: true

class PredictionJobsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  PREDICTION_JOB_MONITOR = ENV.fetch('PREDICTION_JOB_MONITOR', 10).to_i

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def index
    prediction_job_scope = PredictionJob.order(id: :desc).limit(params_page_size)
    render(
      status: :ok,
      json: prediction_job_scope.as_json
    )
  end

  def show
    prediction_job = PredictionJob.find(params[:id])
    render(
      status: :ok,
      json: prediction_job.as_json
    )
  end

  def create
    prediction_job = PredictionJob.create!(
      manifest_url: prediction_job_params[:manifest_url],
      state: :pending
    )

    # use a service here to submit the job to bajor system
    prediction_job = Batch::Prediction::CreateJob.new(prediction_job).run

    # kick off a job monitor here that updates the
    # prediction job resource with the job tasks results
    PredictionJobMonitorJob.perform_in(PREDICTION_JOB_MONITOR.minutes, prediction_job.id) if prediction_job.submitted?


    render status: :created, json: prediction_job.to_json
  end

  private

  def prediction_job_params
    params.require(:prediction_job).permit(:manifest_url)
  end
end
