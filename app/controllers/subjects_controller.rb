# frozen_string_literal: true

class SubjectsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def index
    subject_scope = Subject.preload(:user_reductions).order(id: :desc).limit(params_page_size)
    if params[:zooniverse_subject_id]
      subject_scope = subject_scope.where(zooniverse_subject_id: params[:zooniverse_subject_id])
    end
    render(
      status: :ok,
      json: subject_scope.as_json(include: :user_reductions)
    )
  end

  def show
    subject = Subject.preload(:user_reductions).find(params[:id])
    render(
      status: :ok,
      json: subject.as_json(include: :user_reductions)
    )
  end
end
