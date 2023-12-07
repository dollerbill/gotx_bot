# frozen_string_literal: true

module StreaksHelper
  def streak_status
    return 'Broken streak' if @streak.end_date.present?
    return 'New streak' if @streak.end_date.nil? && @streak.streak_count == 1

    'Active'
  end

  def new_streaks_label(user)
    if user.streaks.one?
      "#{user.name}<sup>(new)</sup>".html_safe
    elsif eternal_streaks?(user)
      "#{user.name}<sup>(returning eternal)</sup>".html_safe
    else
      "#{user.name}<sup>(returning)</sup>".html_safe
    end
  end

  private

  def eternal_streaks?(user)
    user.streaks.any? { |streak| streak.streak_count > 11 }
  end
end
