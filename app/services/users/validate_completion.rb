# frozen_string_literal: true

module Users
  class ValidateCompletion
    attr_reader :user, :game

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @user = atts['user']
      @game = atts['game']
    end

    def call
      return 'Not a valid game.' unless previous_winner?
      return 'You have already recorded a completion for this game.' if previously_completed?
      return 'You have already recorded 3 completions for this month.' if completed_three_games?

      nil
    end

    private

    def previous_winner?
      game&.nominations&.any?(&:winner?)
    end

    def previously_completed?
      (user.completions.map(&:nomination_id) & game.nominations.map(&:id)).any?
    end

    def completed_three_games?
      user.completions.where(completed_at: '2025-01-01'..'2025-01-31').count > 2
    end
  end
end
