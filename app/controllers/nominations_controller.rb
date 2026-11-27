# frozen_string_literal: true

class NominationsController < ApplicationController
  include Pagy::Backend

  before_action :set_nomination, only: %i[show edit update select_winner destroy]

  def index
    @type = %w[gotm rpg retro].include?(params[:type]) ? params[:type] : 'gotm'
    @pagy, @nominations = pagy(Nomination.public_send(@type).joins(:theme).order('themes.creation_date'))
  end

  def current_nominations
    @pagy, nominations = pagy(Nomination.current_nominations.joins(:game).order(:year, :id))
    by_type = nominations.group_by(&:nomination_type)
    @gotm_nominations = by_type.fetch('gotm', [])
    @rpg_nominations = by_type.fetch('rpg', [])
  end

  def show; end

  def new
    @nomination = Nomination.new(theme: Theme.current_gotm_theme.first)
  end

  # Admin-only GotM nomination that bypasses the nomination window (late or missing nominations).
  def create
    @nomination = Nomination.new(params.require(:nomination).permit(:description))
    @nomination.user = User.find(params[:nomination][:user_id])
    @nomination.theme = Theme.gotm.find(params[:nomination][:theme_id])
    @screenscraper_id = params.dig(:nomination, :screenscraper_id).to_s.strip
    game = find_or_scrape_game(@screenscraper_id)
    error = Games::ValidateNomination.('user' => @nomination.user, 'theme' => @nomination.theme, 'game' => game,
                                       'screenscraper_id' => @screenscraper_id, 'skip_window' => true)
    return render_new_with_error(error) if error

    @nomination.update!(game:)
    redirect_to nomination_url(@nomination), notice: "#{game.preferred_name} nominated for #{@nomination.user.name}."
  rescue Scrapers::Screenscraper::GameNotFound, Scrapers::Screenscraper::ApiUnavailable => e
    render_new_with_error("ScreenScraper lookup failed for ID #{@screenscraper_id}: #{e.message}")
  end

  def edit; end

  def update
    if @nomination.update(nomination_params)
      redirect_to nomination_url(@nomination), notice: 'Nomination was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def select_winner
    @nomination.update(winner: true)

    redirect_to current_nominations_path, notice: "#{@nomination.game.preferred_name} marked as a winner!"
  end

  def destroy
    @nomination.destroy
    redirect_to nominations_url, notice: 'Nomination was successfully destroyed.'
  end

  def winners
    if params[:month].present? && params[:year].present?
      date = Date.new(params[:year].to_i, params[:month].to_i, 1)
      @winners = Nomination.gotm.joins(:theme)
                           .where(winner: true)
                           .where('EXTRACT(MONTH FROM themes.creation_date) = ? AND EXTRACT(YEAR FROM themes.creation_date) = ?', date.month, date.year)
    else
      @winners = Nomination.none
    end

    Nomination.joins(:theme)
              .select('DISTINCT EXTRACT(MONTH FROM themes.creation_date) AS month, EXTRACT(YEAR FROM themes.creation_date) AS year')
              .order('year DESC, month DESC')
  end

  private

  def set_nomination
    @nomination = Nomination.find(params[:id])
  end

  def find_or_scrape_game(screenscraper_id)
    Game.find_by(screenscraper_id:) ||
      Game.new(Scrapers::Screenscraper.('screenscraper_id' => screenscraper_id).except(:nominations_attributes))
  end

  def render_new_with_error(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_entity
  end

  def nomination_params
    params.require(:nomination).permit(:description, :winner, :nomination_type)
  end
end
