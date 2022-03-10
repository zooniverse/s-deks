# frozen_string_literal: true

class UserReductionsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: ReductionBasicAuth.username, password: ReductionBasicAuth.password, only: :create

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
