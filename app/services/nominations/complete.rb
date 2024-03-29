# frozen_string_literal: true

module Nominations
  class Complete
    attr_reader :user, :nomination, :points, :skip

    def self.call(user, nomination, skip = nil)
      new(user, nomination, skip).call
    end

    def initialize(user, nomination, skip)
      @user = user
      @nomination = nomination
      @skip = skip
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
      return if skip || !nomination.gotm?

      streak = ::Streaks::FindOrCreate.(user.id)
      return if streak.last_incremented&.month == Date.current.month

      ::Streaks::Increase.(streak)
    end

    def theme_has_completion?
      user.completions.map(&:theme).include?(nomination.theme)
    end
  end
end
