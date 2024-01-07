# frozen_string_literal: true

class GamesController < ApplicationController
  include Helpers::FuzzySearchHelper

  before_action :set_game, only: %i[show edit update]

  def index
    set_search_limit

    @games = if params[:search]&.presence
               ids = Game.fuzzy_search(params[:search]).map(&:id)
               Game.where(id: ids).page(params[:page]).per(25)
             else
               Game.all.order(:title_usa).page(params[:page]).per(25)
             end
  end

  def show; end

  def edit; end

  def create_weekly_retrobit
    game_atts = ::Scrapers::Screenscraper.(screenscraper_params.merge('user' => User.find(12)))
    @game = ::Games::WeeklyRetrobit.(game_atts)

    redirect_to game_url(@game), notice: 'RetroBit was successfully created.'
  end

  def create_monthly_rpg
    game_atts = ::Scrapers::Screenscraper.(screenscraper_params.merge('user' => User.find(12)))
    @game = ::Games::QuarterlyRpg.(game_atts.merge(theme_id: params[:theme_id]))

    redirect_to game_url(@game), notice: 'RPGotQ was successfully created.'
  end

  def update
    if @game.update(game_params)
      redirect_to game_url(@game), notice: 'Game was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game)
          .permit(
            :title_usa,
            :title_world,
            :title_eu,
            :title_other,
            :title_jp,
            :time_to_beat,
            :genre,
            :developer,
            :year,
            :system
          )
  end

  def screenscraper_params
    params.permit('screenscraper_id', 'time_to_beat')
  end
end
