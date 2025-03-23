# frozen_string_literal: true

class ApiController < ActionController::Base
  before_action :authenticate

  def authenticate
    head :forbidden unless authenticate_token
  end

  def authenticate_token
    authenticate_with_http_token do |token|
      token == ENV['API_TOKEN']
    end
  end
end
