# frozen_string_literal: true

module Subscriptions
  class Update
    attr_reader :subscription

    def self.call(subscription)
      new(subscription).call
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def call
      subscription.increment!(:subscribed_months)
      subscription.update!(last_subscribed: Date.current.beginning_of_month)
    end
  end
end
