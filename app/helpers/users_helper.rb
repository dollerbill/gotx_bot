# frozen_string_literal: true

module UsersHelper
  def user_options_for_select
    User.where.not(id: 1).order(:name).pluck(:name, :id)
  end
end
