# frozen_string_literal: true

# == Schema Information
#
# Table name: streaks
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  start_date       :date             not null
#  end_date         :date
#  last_incremented :date
#  streak_count     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Streak < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(end_date: nil).where.not(streak_count: 1) }
  scope :broken, -> { where(end_date: Date.current.last_month.beginning_of_month) }
  scope :newly_started, -> { where(streak_count: 1, end_date: nil) }
end
