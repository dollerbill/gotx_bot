# frozen_string_literal: true

module StreaksHelper
  def streak_status
    return 'Broken streak' if @streak.end_date.present?
    return 'New streak' if @streak.end_date.nil? && @streak.streak_count == 1

    'Active'
  end
end
