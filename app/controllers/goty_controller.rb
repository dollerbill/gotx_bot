# frozen_string_literal: true

class GotyController < ApplicationController
  include GotyHelper

  def show
    @theme = Theme.find(params[:id])
    @nominations = @theme.nominations.includes(:game, :user)
  end

  def create
    year = next_goty_year
    if goty_theme_exists?(year)
      redirect_to root_path, alert: "GotY theme for #{year} already exists"
      return
    end

    theme = Theme.create!(
      title: "GotY #{year}",
      description: "GotY for #{year}",
      creation_date: Date.new(year, 1, 1),
      nomination_type: 'goty'
    )

    # Find the winning game and original nominator if a game was selected
    game = Game.find_by(id: params[:game_id])
    user = nil

    if game
      original_nomination = find_original_nomination(game, year)
      user = original_nomination&.user
    end

    theme.nominations.create!(description: "#{year} GotY Winner", nomination_type: 'goty', winner: true, game:, user:)

    redirect_to goty_path(theme)
  end

  def eligible_games
    theme = Theme.find(params[:id])
    eligible_year = theme.creation_date.year

    render json: fetch_eligible_games(eligible_year)
  end

  def eligible_games_for_year
    eligible_year = next_goty_year

    render json: fetch_eligible_games(eligible_year)
  end

  def add_nomination
    @theme = Theme.find(params[:id])

    if params[:description].blank?
      redirect_to goty_path(@theme), alert: 'Category name is required'
      return
    end

    game = Game.find_by(id: params[:game_id])
    eligible_year = @theme.creation_date.year
    original_nomination = find_original_nomination(game, eligible_year)

    if original_nomination.nil?
      redirect_to goty_path(@theme), alert: 'Could not find a winning nomination for this game in the eligible year'
      return
    end

    @theme.nominations.create!(
      description: params[:description],
      nomination_type: 'goty',
      winner: true,
      game:,
      user: original_nomination.user
    )

    redirect_to goty_path(@theme), notice: 'Category winner added successfully'
  end

  private

  def fetch_eligible_games(eligible_year)
    Nomination.joins(:theme)
              .where(winner: true)
              .where(nomination_type: %w[gotm retro])
              .where('EXTRACT(YEAR FROM themes.creation_date) = ?', eligible_year)
              .includes(:game, :user)
              .map { |n| { id: n.game_id, name: n.game.preferred_name, nominator_id: n.user_id } }
              .uniq { |g| g[:id] }
  end

  def find_original_nomination(game, eligible_year)
    Nomination.joins(:theme)
              .where(game:, winner: true)
              .where(nomination_type: %w[gotm retro])
              .where('EXTRACT(YEAR FROM themes.creation_date) = ?', eligible_year)
              .first
  end
end
