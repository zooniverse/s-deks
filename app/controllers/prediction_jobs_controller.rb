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
    begin
      prediction_job = PredictionJob.create!(create_params_with_defaults)
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
    permitted_params = %i[manifest_url subject_set_id probability_threshold randomisation_factor]
    params.require(:prediction_job).permit(*permitted_params)
  end

  # simple approch for first GZ project use case
  # set defaults for these attributes
  # via env vars for the GZ project this was built for
  # these can be overriden at runtime via API params
  # or as more projects use this system then remove this implementation of these ENV defaults
  # and leave it up to the clients to knows values to set at runtime (they provide the context)
  def create_params_with_defaults
    prediction_job_params.with_defaults(
      state: :pending,
      # subject_set_id default must be set for each environment
      subject_set_id: ENV.fetch('PREDICTION_JOB_SUBJECT_SET_ID_DEFAULT'),
      # threshold on subjects 80% predicted not likely to be smooth
      probability_threshold: ENV.fetch('PREDICTION_JOB_PROBABILITY_THRESHOLD_DEFAULT', '0.8').to_f,
      # attempt to add 10% of the 'smooth' prediction subjects for some randomisation of the data (avoid overfitting the model etc)
      randomisation_factor: ENV.fetch('PREDICTION_JOB_RANDOMISATION_FACTOR_DEFAULT', '0.1').to_f
    )
  end
end
