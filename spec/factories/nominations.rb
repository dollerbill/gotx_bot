# frozen_string_literal: true

FactoryBot.define do
  factory :nomination do
    nomination_type { 'gotm' }
    description { 'Nomination for a game!' }
    game { build(:game) }
    user { create(:user) }
    theme { create(:theme) }

    trait :winner do
      winner { true }
    end

    trait :retro do
      nomination_type { 'retro' }
      theme { build(:theme, :retro) }
    end

    trait :rpg do
      nomination_type { 'rpg' }
      theme { build(:theme, :rpg) }
    end

    trait :goty do
      nomination_type { 'goty' }
      theme { build(:theme, :goty) }
    end
  end
end
