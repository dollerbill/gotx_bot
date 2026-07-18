# frozen_string_literal: true

class GotyController < ApplicationController
  include GotyHelper

  before_action :set_theme, only: %i[show eligible_games add_nomination eligible_gotw_games add_gotwoty_nomination]

  def show
    @nominations = @theme.nominations.includes(:game, :user)

    @gotwoty_theme = find_gotwoty_theme
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
    render json: eligible_games_json(eligible_year, Nomination::GOTY_ELIGIBLE_TYPES)
  end

  def eligible_games_for_year
    render json: eligible_games_json(next_goty_year, Nomination::GOTY_ELIGIBLE_TYPES)
  end

  def add_nomination
    if params[:description].blank?
      redirect_to goty_path(@theme), alert: 'Category name is required'
      return
    end

    game = Game.find_by(id: params[:game_id])
    original_nomination = find_original_nomination(game, eligible_year, Nomination::GOTY_ELIGIBLE_TYPES)

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
    render json: eligible_games_json(eligible_year, Nomination::GOTWOTY_ELIGIBLE_TYPES)
  end

  def add_gotwoty_nomination
    goty_theme = @theme

    game = Game.find_by(id: params[:game_id])

    if game.nil?
      redirect_to goty_path(goty_theme), alert: 'Please select a game'
      return
    end

    original_nomination = find_original_nomination(game, eligible_year, Nomination::GOTWOTY_ELIGIBLE_TYPES)

    if original_nomination.nil?
      redirect_to goty_path(goty_theme), alert: 'Could not find a winning GotW nomination for this game in the eligible year'
      return
    end

    gotwoty_theme = find_gotwoty_theme

    if gotwoty_theme&.nominations&.any?
      redirect_to goty_path(goty_theme), alert: 'GotWotY winner has already been selected for this year'
      return
    end

    gotwoty_theme ||= Theme.create!(
      title: "GotWotY #{eligible_year}",
      description: "GotWotY for #{eligible_year}",
      creation_date: Date.new(eligible_year, 1, 1),
      nomination_type: 'gotwoty'
    )

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

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def eligible_year
    @theme.creation_date.year
  end

  def find_gotwoty_theme
    Theme.find_by(nomination_type: 'gotwoty', creation_date: Date.new(eligible_year, 1, 1))
  end

  def eligible_games_json(year, types)
    Nomination.goty_eligible(year, types)
              .includes(:game, :user)
              .map { |n| { id: n.game_id, name: n.game.preferred_name, nominator_id: n.user_id } }
              .uniq { |g| g[:id] }
  end

  def find_original_nomination(game, year, types)
    Nomination.goty_eligible(year, types).where(game:).first
  end
end
