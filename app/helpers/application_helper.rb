# frozen_string_literal: true

module ApplicationHelper
  def in_est_zone(time)
    time.in_time_zone('EST').strftime('%H:%M %Z %m-%d-%Y')
  end

  def lazy_render(attribute, label)
    content_tag(:p, "<strong>#{label}:</strong> #{attribute}".html_safe) if attribute
  end
end
