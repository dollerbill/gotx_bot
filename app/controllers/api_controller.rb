# frozen_string_literal: true

class ApiController < ActionController::Base
  before_action :authenticate

  def authenticate
    head :forbidden unless authenticate_token
  end

  def authenticate_token
    expected = ENV['API_TOKEN']
    authenticate_with_http_token do |token|
      expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)
    end
  end
end
