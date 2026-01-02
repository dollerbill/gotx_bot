# frozen_string_literal: true

class HomeController < ApplicationController
  include GotyHelper

  before_action :basic_authenticate
  skip_before_action :ensure_admin_authenticated

  def index; end

  private

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      valid = ENV['ADMIN_USER_NAMES'].split(',').any? { |name| name.casecmp?(username) } &&
              password == ENV['ADMIN_UI_PASSWORD']

      if valid
        session[:admin_authenticated] = true
        return true
      end
      false
    end
  end
end
