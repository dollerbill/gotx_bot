# frozen_string_literal: true

class GotyController < ApplicationController
  include GotyHelper

  def show
    @theme = Theme.find(params[:id])
    @nominations = @theme.nominations.includes(:game, :user)

    eligible_year = @theme.creation_date.year
    @gotwoty_theme = Theme.find_by(
      nomination_type: 'gotwoty',
      creation_date: Date.new(eligible_year, 1, 1)
    )
    @gotwoty_winner = @gotwoty_theme&.nominations&.first
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

  def eligible_gotw_games
    theme = Theme.find(params[:id])
    eligible_year = theme.creation_date.year

    render json: fetch_eligible_gotw_games(eligible_year)
  end

  def add_gotwoty_nomination
    goty_theme = Theme.find(params[:id])

    game = Game.find_by(id: params[:game_id])

    if game.nil?
      redirect_to goty_path(goty_theme), alert: 'Please select a game'
      return
    end

    eligible_year = goty_theme.creation_date.year
    original_nomination = find_original_gotw_nomination(game, eligible_year)

    if original_nomination.nil?
      redirect_to goty_path(goty_theme), alert: 'Could not find a winning GotW nomination for this game in the eligible year'
      return
    end

    gotwoty_theme = Theme.find_by(
      nomination_type: 'gotwoty',
      creation_date: Date.new(eligible_year, 1, 1)
    )

    if gotwoty_theme&.nominations&.any?
      redirect_to goty_path(goty_theme), alert: 'GotWotY winner has already been selected for this year'
      return
    end

    if gotwoty_theme.nil?
      gotwoty_theme = Theme.create!(
        title: "GotWotY #{eligible_year}",
        description: "GotWotY for #{eligible_year}",
        creation_date: Date.new(eligible_year, 1, 1),
        nomination_type: 'gotwoty'
      )
    end

    gotwoty_theme.nominations.create!(
      description: "#{eligible_year} GotWotY Winner",
      nomination_type: 'gotwoty',
      winner: true,
      game:,
      user: original_nomination.user
    )

    redirect_to goty_path(goty_theme), notice: 'GotWotY winner added successfully'
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

  def fetch_eligible_gotw_games(eligible_year)
    Nomination.joins(:theme)
              .where(winner: true)
              .where(nomination_type: 'retro')
              .where('EXTRACT(YEAR FROM themes.creation_date) = ?', eligible_year)
              .includes(:game, :user)
              .map { |n| { id: n.game_id, name: n.game.preferred_name, nominator_id: n.user_id } }
              .uniq { |g| g[:id] }
  end

  def find_original_gotw_nomination(game, eligible_year)
    Nomination.joins(:theme)
              .where(game:, winner: true)
              .where(nomination_type: 'retro')
              .where('EXTRACT(YEAR FROM themes.creation_date) = ?', eligible_year)
              .first
  end
end
