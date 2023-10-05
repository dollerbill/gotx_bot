# frozen_string_literal: true

FactoryBot.define do
  factory :streak do
    user { build(:user) }
    start_date { Date.today.last_month.beginning_of_month }

    trait :active do
      streak_count { 1 }
      last_incremented { Date.today.last_month.beginning_of_month }
    end

    trait :broken do
      end_date { Date.today.beginning_of_month }
    end
  end
end
