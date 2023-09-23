# frozen_string_literal: true

module Streaks
  class FindOrCreate
    attr_reader :user_id

    def self.call(user_id)
      new(user_id).call
    end

    def initialize(user_id)
      @user_id = user_id
    end

    def call
      Streak.active.find_by(user_id:) || Streak.create!(start_date: Date.current.beginning_of_month, user_id:)
    end
  end
end
