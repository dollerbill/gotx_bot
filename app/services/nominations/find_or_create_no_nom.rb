# frozen_string_literal: true

module Nominations
  class FindOrCreateNoNom
    attr_reader :game, :theme_id

    def self.call(game)
      new(game).call
    end

    def initialize(game)
      @game = game
      @theme_id = Theme.gotm
                       .where('EXTRACT(YEAR FROM themes.creation_date) = ?', Date.current.year)
                       .where('title ilike ?', '%learning old lessons%')
                       .last
                       .id
    end

    def call
      (nomination = Nomination.find_by(game_id: game.id, theme_id:)) ? nomination : create_nomination
    end

    private

    def create_nomination
      Nomination.create(user_id: 12, game:, theme_id:)
    end
  end
end
