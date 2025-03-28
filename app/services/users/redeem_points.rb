# frozen_string_literal: true

module Users
  class RedeemPoints
    attr_reader :user, :points

    def self.call(user, points)
      new(user, points).call
    end

    def initialize(user, points)
      @user = user
      @points = points.to_f
    end

    def call
      redeem_points if points_available?
    end

    private

    def points_available?
      true if user.current_points >= points
    end

    def redeem_points
      user.decrement!(:current_points, points)
      user.increment!(:redeemed_points, points)
    end
  end
end
