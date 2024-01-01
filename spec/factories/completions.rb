# frozen_string_literal: true

FactoryBot.define do
  factory :completion do
    completed_at { Date.current }
    nomination { build(:nomination) }
    user { build(:user) }

    trait :rpg do
      nomination { build(:nomination, :rpg) }
    end

    trait :retro do
      nomination { build(:nomination, :retro) }
    end

    trait :goty do
      nomination { build(:nomination, :goty) }
    end
  end
end
