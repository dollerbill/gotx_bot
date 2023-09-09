# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :ensure_admin_authenticated

  private

  def ensure_admin_authenticated
    redirect_to root_path unless session[:admin_authenticated]
  end
end
