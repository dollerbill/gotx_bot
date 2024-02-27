# frozen_string_literal: true

class NominationsController < ApplicationController
  include Pagy::Backend

  before_action :set_nomination, only: %i[show edit update select_winner destroy]

  def index
    @type = %w[gotm rpg retro].include?(params[:type]) ? params[:type] : 'gotm'
    @pagy, @nominations = pagy(Nomination.public_send(@type))
  end

  def current_nominations
    @pagy, @nominations = pagy(Nomination.current_nominations)
  end

  def show; end

  def new
    @nomination = Nomination.new
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

  # rubocop:disable Layout/LineLength
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
  # rubocop:enable Layout/LineLength

  private

  def set_nomination
    @nomination = Nomination.find(params[:id])
  end

  def nomination_params
    params.require(:nomination).permit(:description, :winner, :nomination_type)
  end
end
