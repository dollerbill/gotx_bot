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
FactoryBot.define do
  factory :streak do
    streak_count { 1 }
    user { build(:user) }
    start_date { Date.current.last_month.beginning_of_month }

    trait :active do
      streak_count { 2 }
      last_incremented { Date.current.last_month.beginning_of_month }
    end

    trait :broken do
      end_date { Date.current.beginning_of_month }
    end
  end
end
