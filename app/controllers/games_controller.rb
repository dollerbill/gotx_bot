# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update]

  def index
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
    game_atts = ::Scrapers::Screenscraper.(screenscraper_params.merge('user_id' => 12))
    game_atts[:nominations_attributes][0][:theme] = Theme.create!
    game_atts[:nominations_attributes][0][:nomination_type] = 'retro'
    @game = Game.create!(game_atts)

    redirect_to game_url(@game), notice: 'RetroBit was successfully created.'
  end

  def create_monthly_rpg
    game_atts = ::Scrapers::Screenscraper.(screenscraper_params.merge('user_id' => 12))
    game_atts[:nominations_attributes][0][:theme_id] = params[:theme_id]
    game_atts[:nominations_attributes][0][:nomination_type] = 'rpg'
    @game = Game.create!(game_atts)

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
    params.permit('screenscraper_id')
  end
end
