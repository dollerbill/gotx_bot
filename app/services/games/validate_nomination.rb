# frozen_string_literal: true

module Games
  class ValidateNomination
    attr_reader :user, :screenscraper_id, :game, :theme

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @user = atts['user']
      @screenscraper_id = atts['screenscraper_id']
      @game = atts['game'] || Game.find_by(screenscraper_id:)
      # Admin-added nominations pass an explicit theme and bypass the nomination window.
      @theme = atts['theme']
      @skip_window = atts['skip_window']
    end

    def call
      return I18n.t('nominations.closed', time: Nomination.nominations_open_est) unless @skip_window || Nomination.open?
      return I18n.t('nominations.existing_user_nomination') if user_already_nominated?
      return I18n.t('nominations.existing_game_nomination', game: @game.preferred_name) if game_already_nominated?
      return I18n.t('nominations.category_full', category: game.era) if category_full?
      return I18n.t('nominations.previous_rpg_winner') if previous_rpg_winner?
      return I18n.t('nominations.previous_weekly_winner') if previous_weekly_winner?
      return unless previously_won?

      I18n.t('nominations.previous_nomination', game: @game.preferred_name, id: screenscraper_id)
    end

    private

    def previously_won?
      @game&.nominations&.gotm&.any?(&:winner)
    end

    def previous_rpg_winner?
      @game&.nominations&.joins(:theme)&.rpg&.winners&.where(theme: { creation_date: 1.year.ago.. })&.any?
    end

    def previous_weekly_winner?
      @game&.nominations&.joins(:theme)&.retro&.winners&.where(theme: { creation_date: 1.year.ago.. })&.any?
    end

    def in_theme(nominations)
      theme ? nominations.where(theme:) : nominations.current_nominations
    end

    def user_already_nominated?
      in_theme(user.nominations).gotm.any?
    end

    def game_already_nominated?
      @game.present? && in_theme(@game.nominations).gotm.any?
    end

    def category_full?
      return false unless game&.era

      in_theme(Nomination.gotm).joins(:game).merge(Game.in_era(game.era)).count >= Nomination::CATEGORY_LIMIT
    end
  end
end
