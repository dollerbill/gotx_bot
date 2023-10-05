# frozen_string_literal: true

module Streaks
  class EndBroken
    LAST_MONTH = Date.current.last_month.beginning_of_month

    def self.call
      new.call
    end

    def call
      Streak.where(end_date: nil).where.not(last_incremented: LAST_MONTH..).find_each do |streak|
        streak.update(end_date: LAST_MONTH)
      end
    end
  end
end
