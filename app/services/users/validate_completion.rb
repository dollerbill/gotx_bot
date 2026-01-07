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
      return ' has already recorded a completion for this game.' if previously_completed?
      return ' has already recorded 3 completions for this month.' if completed_three_games?

      nil
    end

    private

    def previously_completed?
      (user.completions.map(&:nomination_id) & game.nominations.map(&:id)).any?
    end

    def completed_three_games?
      current_month_start = Date.current.beginning_of_month
      current_month_end = Date.current.end_of_month
      user.completions.joins(:nomination).where(completed_at: current_month_start..current_month_end, nomination: { nomination_type: 'gotm' }).count > 2
    end
  end
end
