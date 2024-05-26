# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  name               :string           not null
#  discord_id         :bigint
#  old_discord_name   :string
#  current_points     :float            default(0.0)
#  redeemed_points    :float            default(0.0)
#  earned_points      :float            default(0.0)
#  premium_points     :float            default(0.0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  premium_subscriber :string
#
FactoryBot.define do
  factory :user do
    name { ('a'..'z').to_a.sample(6).join }
    discord_id { (0..17).map { rand(9) }.join }
    old_discord_name { "#{('a'..'z').to_a.sample(6).join}#0001" }
    current_points { 0.0 }
    redeemed_points { 0.0 }
    earned_points { 0.0 }
    premium_points { 0.0 }

    trait :current_points do
      current_points { 150.0 }
      redeemed_points { 0.0 }
      earned_points { 100.0 }
      premium_points { 500.0 }
    end

    trait :redeemed_points do
      current_points { 0.0 }
      redeemed_points { 99.0 }
      earned_points { 95.0 }
      premium_points { 4.0 }
    end

    trait :legend do
      premium_subscriber { 'legend' }
    end

    trait :champion do
      premium_subscriber { 'champion' }
    end

    trait :supporter do
      premium_subscriber { 'supporter' }
    end
  end
end
