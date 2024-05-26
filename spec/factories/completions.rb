# frozen_string_literal: true

# == Schema Information
#
# Table name: completions
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime         not null
#  nomination_id :bigint
#  user_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :completion do
    completed_at { Date.today }
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
