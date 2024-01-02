# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user { build(:user) }
    subscribed_months { 5 }

    trait :active do
      last_subscribed { Date.current.last_month.beginning_of_month }
    end

    trait :cancelled do
      start_date { 5.months.ago.beginning_of_month }
      end_date { Date.current.beginning_of_month }
    end

    trait :newly_subscribed do
      subscribed_months { 1 }
      last_subscribed { Date.current.beginning_of_month }
    end
  end
end
