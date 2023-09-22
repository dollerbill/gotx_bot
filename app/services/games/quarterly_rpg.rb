# frozen_string_literal: true

module Games
  class QuarterlyRpg < CreateRecurring
    def call
      create_game
    end

    private

    def theme
      Theme.find(atts.delete(:theme_id))
    end

    def nomination_type
      'rpg'
    end
  end
end
