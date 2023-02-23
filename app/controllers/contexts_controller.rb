# frozen_string_literal: true

class ContextsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password
  )

  def index
    contexts_scope = Context.order(id: :desc).limit(params_page_size)
    render(
      status: :ok,
      json: contexts_scope.as_json
    )
  end

  def show
    context = Context.find(params[:id])
    render(
      status: :ok,
      json: context.as_json
    )
  end
end
