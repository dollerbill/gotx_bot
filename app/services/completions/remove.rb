# frozen_string_literal: true

module Completions
  class Remove
    attr_reader :completion, :points, :streak

    def self.call(completion)
      new(completion).call
    end

    def initialize(completion)
      @completion = completion
      @points = Completion::COMPLETION_POINTS[completion.nomination.nomination_type]
      @streak = Streak.active.find_by(user: completion.user)
    end

    def call
      completion.destroy!
      update_streak
      Users::RemovePoints.(completion.user, points)
    end

    private

    def update_streak
      return unless streak && completion.nomination.gotm?

      Streaks::Decrease.(streak)
    end
  end
end
