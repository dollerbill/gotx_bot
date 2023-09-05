# frozen_string_literal: true

module Games
  class ValidateNomination
    attr_reader :atts

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @atts = atts
    end

    def call
      return I18n.t('nominations.closed', time: Nomination.nominations_open) unless Nomination.open?
      return I18n.t('nominations.existing_nomination') if existing_nomination?
      return unless previously_nominated?

      I18n.t('nominations.previous_nomination', game: @game.preferred_name, id: atts['screenscraper_id'])
    end

    private

    def previously_nominated?
      @game = Game.find_by(screenscraper_id: atts['screenscraper_id'])
    end

    def existing_nomination?
      Nomination.current_nominations.find_by(user_id: atts['user_id'])
    end
  end
end
