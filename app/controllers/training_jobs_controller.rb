# frozen_string_literal: true

class TrainingJobsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def index
    training_job_scope = TrainingJob.order(id: :desc).limit(params_page_size)
    render(
      status: :ok,
      json: training_job_scope.as_json
    )
  end

  def show
    training_job = TrainingJob.find(params[:id])
    render(
      status: :ok,
      json: training_job.as_json
    )
  end
end
