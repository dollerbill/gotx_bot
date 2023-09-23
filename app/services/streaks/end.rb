# frozen_string_literal: true

module Streaks
  class End
    attr_reader :streak

    def self.call(streak)
      new(streak).call
    end

    def initialize(streak)
      @streak = streak
    end

    def call
      streak.update(end_date: Date.current.last_month.beginning_of_month)
    end
  end
end
