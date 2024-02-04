# frozen_string_literal: true

module Streaks
  class Decrease
    attr_reader :streak

    def self.call(streak)
      new(streak).call
    end

    def initialize(streak)
      @streak = streak
    end

    def call
      return streak.destroy! if streak.streak_count == 1

      previously_incremented = streak.last_incremented
      streak.decrement!(:streak_count)
      streak.update(last_incremented: previously_incremented - 1.month)
    end
  end
end
