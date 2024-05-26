# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id              :bigint           not null, primary key
#  creation_date   :date             not null
#  title           :string           not null
#  description     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nomination_type :string           default("gotm")
#
FactoryBot.define do
  factory :theme do
    creation_date { Date.current.beginning_of_month }
    title { 'Fantastic February' }
    description { 'Games that are just swell.' }
    nomination_type { 'gotm' }

    trait :goty do
      nomination_type { 'goty' }
    end

    trait :gotwoty do
      nomination_type { 'gotwoty' }
    end

    trait :retro do
      nomination_type { 'retro' }
    end

    trait :rpg do
      nomination_type { 'rpg' }
    end

    trait :previous do
      creation_date { 3.months.ago.beginning_of_month }
    end
  end
end
