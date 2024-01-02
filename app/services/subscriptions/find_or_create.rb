# frozen_string_literal: true

module Subscriptions
  class FindOrCreate
    attr_reader :user

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      user.subscriptions.active.first || Subscription.create!(subscription_type: user.premium_subscriber, user:)
    end
  end
end
