# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :basic_authenticate
  skip_before_action :ensure_admin_authenticated

  def index; end

  private

  def basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      if ENV['ADMIN_USER_NAMES'].split(',').any? { |name| name.casecmp?(username) } &&
         password == ENV['ADMIN_UI_PASSWORD']
        session[:admin_authenticated] = true
      end
    end
  end
end
