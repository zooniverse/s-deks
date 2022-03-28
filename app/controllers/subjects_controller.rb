# frozen_string_literal: true

class SubjectsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def index
    subject_scope = Subject.all
    if params[:zooniverse_subject_id]
      subject_scope = subject_scope.where(zooniverse_subject_id: params[:zooniverse_subject_id])
    end
    render status: :ok, json: subject_scope.to_json
  end

  def show
    subject = Subject.find(params[:id])
    render status: :ok, json: subject.to_json
  end
end
