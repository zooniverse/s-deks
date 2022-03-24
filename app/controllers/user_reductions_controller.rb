# frozen_string_literal: true

class UserReductionsController < ApplicationController
  # as we're running in API mode we need to include basic auth
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # ensure we include the non model attributes in the user_reduction nested payload
  # https://api.rubyonrails.org/v7.0.2.3/classes/ActionController/ParamsWrapper.html
  wrap_parameters UserReduction, include: %w[id reducible data subject]

  http_basic_authenticate_with(
    name: Rails.application.config.user_reduction_basic_auth_username,
    password: Rails.application.config.user_reduction_basic_auth_password,
    only: :create
  )

  def create
    debugger
    # so the payload doesn't conform to the expected format for strong params
    # Started POST "/user_reductions" for 10.244.6.79 at 2022-03-24 15:36:58 +0000
    # I, [2022-03-24T15:36:58.576861 #1]  INFO -- : [3c9799100bace703fe82f97187bc97a8] Processing by UserReductionsController#create as JSON
    # I, [2022-03-24T15:36:58.577022 #1]  INFO -- : [3c9799100bace703fe82f97187bc97a8]   Parameters: {"id"=>1659, "reducible"=>{"id"=>3598, "type"=>"Workflow"}, "data"=>{"1"=>1}, "subject"=>{"id"=>85082, "metadata"=>{"!Image"=>"http://skyserver.sdss.org/dr8/en/tools/explore/obj.asp?id=1237648721216078463", "!SDSS_ID"=>"1237648721216078463", "Galaxy_ID"=>"5", "image_file"=>"1237648721216078463.jpeg", "!GZ_Original_Merger"=>"0", "!GZ_Original_Spiral"=>"31", "!GZ_Original_Artifact"=>"1", "!GZ_Original_Elliptical"=>"0", "!Computer_Classification"=>"Not Elliptical"}, "created_at"=>"2020-03-30T19:55:06.539Z", "updated_at"=>"2020-03-30T19:55:06.539Z"}, "reducer_key"=>"[FILTERED]", "created_at"=>"2022-03-24T15:24:10.052Z", "updated_at"=>"2022-03-24T15:24:10.052Z", "user_reduction"=>{"id"=>1659, "created_at"=>"2022-03-24T15:24:10.052Z", "updated_at"=>"2022-03-24T15:24:10.052Z"}}
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
