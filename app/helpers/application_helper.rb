# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def in_est_zone(time)
    time.in_time_zone('EST').strftime('%H:%M %Z %m-%d-%Y')
  end
end
