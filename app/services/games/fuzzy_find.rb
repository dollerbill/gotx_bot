# frozen_string_literal: true

module Games
  class FuzzyFind
    include Helpers::FuzzySearchHelper

    attr_reader :search_term

    def self.call(search_term)
      new(search_term).call
    end

    def initialize(search_term)
      @search_term = search_term
    end

    def call
      set_search_limit

      results = {}

      %i[usa world eu jp other].each { |region| results[region] = Game.fuzzy_search("title_#{region}": search_term) }
      games = results.values.flatten
      games.find { |game| game.preferred_name.casecmp?(search_term) } || games.first
    end
  end
end
