# frozen_string_literal: true

module ThemesHelper
  def most_recent_theme(type)
    Theme.most_recent(type).first
  end
end
