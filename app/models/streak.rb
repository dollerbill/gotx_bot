# frozen_string_literal: true

class Streak < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(end_date: nil).where.not(streak_count: 1) }
  scope :broken, -> { where(end_date: Date.current.last_month.beginning_of_month) }
  scope :newly_started, -> { where(streak_count: 1, end_date: nil) }
end
