# frozen_string_literal: true

class PredictionJobsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

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

    begin
      # attempt to submit the job directly
      prediction_job = PredictionJobSubmissionJob.new.perform(prediction_job.id)
    rescue PredictionJobSubmissionJob::Failure => _e
      # schedule the job submission in the background
      prediction_job = PredictionJobSubmissionJob.perform_async(prediction_job.id)
    end

    render status: :created, json: prediction_job.to_json
  end

  private

  def prediction_job_params
    params.require(:prediction_job).permit(:manifest_url)
  end
end
