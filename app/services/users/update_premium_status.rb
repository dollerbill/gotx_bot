# frozen_string_literal: true

module Users
  class UpdatePremiumStatus
    attr_reader :user, :membership_status

    def self.call(user, membership_status)
      new(user, membership_status).call
    end

    def initialize(user, membership_status)
      @user = user
      @membership_status = membership_status
    end

    def call
      user.update!(premium_subscriber: membership_status)
    end
  end
end
