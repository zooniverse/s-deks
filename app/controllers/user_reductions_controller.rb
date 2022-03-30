# frozen_string_literal: true

class UserReductionsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # ensure we include the non model attributes in the user_reduction nested payload
  # https://api.rubyonrails.org/v7.0.2.3/classes/ActionController/ParamsWrapper.html
  wrap_parameters UserReduction, include: %w[id reducible data subject]

  http_basic_authenticate_with(
    name: Rails.application.config.user_reduction_basic_auth_username,
    password: Rails.application.config.user_reduction_basic_auth_password
  )

  def index
    user_reduction_scope = UserReduction.preload(:subject).order(id: :desc).limit(params_page_size)
    if params[:zooniverse_subject_id]
      user_reduction_scope = user_reduction_scope.where(zooniverse_subject_id: params[:zooniverse_subject_id])
    end
    render(
      status: :ok,
      json: user_reduction_scope.as_json(include: :subject)
    )
  end

  def show
    user_reduction = UserReduction.preload(:subject).find(params[:id])
    render(
      status: :ok,
      json: user_reduction.as_json(include: :subject)
    )
  end

  def create
    user_reduction = Import::UserReduction.new(user_reduction_params).run
    render status: :created, json: user_reduction.to_json
  end

  private

  def user_reduction_params
    # as this API is internally facing only - ingesting from caesar, we have a controlled payload schema
    # so we can allow an open schema of the payload body / what can be saved to the db
    # longer term if needed we can look at validating via a json schema if required
    params.permit(user_reduction: {})[:user_reduction]
  end
end
