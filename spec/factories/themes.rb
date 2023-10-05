# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    creation_date { Date.current.beginning_of_month }
    title { 'Fantastic February' }
    description { 'Games that are just swell.' }
    nomination_type { 'gotm' }

    trait :goty do
      nomination_type { 'goty' }
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
