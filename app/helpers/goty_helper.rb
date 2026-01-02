# frozen_string_literal: true

module GotyHelper
  def next_goty_year
    last_goty = Theme.goty.order(creation_date: :desc).first
    return Date.current.year if last_goty.nil?

    last_goty.creation_date.year + 1
  end

  def eligible_goty_year
    next_goty_year
  end

  def goty_theme_exists?(year)
    Theme.goty.where('EXTRACT(YEAR FROM creation_date) = ?', year).exists?
  end
end
