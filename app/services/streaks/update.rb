# frozen_string_literal: true

module Streaks
  class Update
    attr_reader :streak

    def self.call(streak)
      new(streak).call
    end

    def initialize(streak)
      @streak = streak
    end

    def call
      streak.increment!(:streak_count)
      streak.update!(last_incremented: Date.current.beginning_of_month)
    end
  end
end
