# frozen_string_literal: true

module Nominations
  class Complete
    attr_reader :user, :nomination, :points

    def self.call(user, nomination)
      new(user, nomination).call
    end

    def initialize(user, nomination)
      @user = user
      @nomination = nomination
      @points = Completion::COMPLETION_POINTS[nomination.nomination_type]
    end

    def call
      ActiveRecord::Base.transaction do
        Completion.create!(user_id: user.id, nomination_id: nomination.id, completed_at: Time.now)
        update_streak
        Users::AddPoints.(user, points)
      end
    end

    private

    def update_streak
      # past-month completions (admin backfills) don't count toward the current streak
      return unless Nomination.current_gotm_winners.exists?(nomination.id)

      streak = ::Streaks::FindOrCreate.(user.id)
      return if streak.last_incremented&.month == Date.current.month

      ::Streaks::Increase.(streak)
    end

    def theme_has_completion?
      user.completions.map(&:theme).include?(nomination.theme)
    end
  end
end
