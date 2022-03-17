# frozen_string_literal: true

class TrainingDataExportsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.config.api_basic_auth_username,
    password: Rails.application.config.api_basic_auth_password,
    only: :create
  )

  def create
    training_data_export = TrainingDataExport.create(
      storage_path: storage_path_key,
      workflow_id: training_data_export_params[:workflow_id]
    )

    # TODO: long term move this to a background worker
    Export::TrainingData.new(training_data_export).run

    render status: :created, json: training_data_export.to_json
  end

  private

  def training_data_export_params
    params.require(:training_data_export).permit(:workflow_id)
  end

  def storage_path_key
    # use the timestamp here to ensure we have a unique export path
    # for active storage has_one_attached and the container files
    "#{Zoobot.storage_path_key(training_data_export_params[:workflow_id])}-#{Time.now.iso8601}.csv"
  end
end
