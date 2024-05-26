# frozen_string_literal: true

# == Schema Information
#
# Table name: nominations
#
#  id              :bigint           not null, primary key
#  nomination_type :string           default("gotm"), not null
#  description     :string
#  winner          :boolean          default(FALSE)
#  game_id         :bigint
#  user_id         :bigint
#  theme_id        :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
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
