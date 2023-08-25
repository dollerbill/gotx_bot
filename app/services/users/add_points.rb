# frozen_string_literal: true

module Users
  class AddPoints
    attr_reader :user, :points

    def self.call(user, points)
      new(user, points).call
    end

    def initialize(user, points)
      @user = user
      @points = points
    end

    def call
      user.increment!(:earned_points, points)
      user.increment!(:current_points, points)
      user.reload
    end
  end
end
