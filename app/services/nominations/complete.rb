# frozen_string_literal: true

module Nominations
  class Complete
    COMPLETION_POINTS = {
      'gotm' => 1,
      'retro' => 0.5,
      'rpg' => 1
    }.freeze

    attr_reader :user, :nomination, :points

    def self.call(user, nomination)
      new(user, nomination).call
    end

    def initialize(user, nomination)
      @user = user
      @nomination = nomination
      @points = COMPLETION_POINTS[nomination.nomination_type]
    end

    def call
      Completion.create!(user_id: user.id, nomination_id: nomination.id, completed_at: Time.now)
      Users::AddPoints.(user, points)
    end
  end
end
