# frozen_string_literal: true

module Subscriptions
  class UpdateMonthly
    def self.call
      new.call
    end

    def call
      User.transaction do
        User.premium.each do |user|
          sub = Subscriptions::FindOrCreate.(user)
          Subscriptions::Update.(sub)
        end
      end
    end
  end
end
