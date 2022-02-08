# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render json: {
      status: "ok",
      database_status: db_connection_status,
      commit_id: ENV['REVISION']
    }.to_json
  end

  private

  def db_connection_status
    ActiveRecord::Base.connected? ? 'connected' : 'not-connected'
  end
end
