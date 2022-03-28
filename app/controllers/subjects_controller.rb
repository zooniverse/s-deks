# frozen_string_literal: true

class SubjectsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def show
    subject = Subject.find(params[:id])
    render status: :ok, json: subject.to_json
  end
end
