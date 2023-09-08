# frozen_string_literal: true

class NominationsController < ApplicationController
  before_action :set_nomination, only: %i[show edit update destroy select_winner]

  def index
    @type = params[:type] || 'gotm'
    @nominations = Nomination.public_send(@type).page(params[:page]).per(25)
  end

  def current_nominations
    @nominations = Nomination.current_nominations.page(params[:page]).per(25)
  end

  def show; end

  def new
    @nomination = Nomination.new
  end

  def edit; end

  def create
    @nomination = Nomination.new(nomination_params)

    respond_to do |format|
      if @nomination.save
        format.html { redirect_to nomination_url(@nomination), notice: 'Nomination was successfully created.' }
        format.json { render :show, status: :created, location: @nomination }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @nomination.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @nomination.update(nomination_params)
        format.html { redirect_to nomination_url(@nomination), notice: 'Nomination was successfully updated.' }
        format.json { render :show, status: :ok, location: @nomination }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @nomination.errors, status: :unprocessable_entity }
      end
    end
  end

  def select_winner
    @nomination.update(winner: true)

    redirect_to current_nominations_path, notice: "#{@nomination.game.preferred_name} marked as a winner!"
  end

  def destroy
    @nomination.destroy

    respond_to do |format|
      format.html { redirect_to nominations_url, notice: 'Nomination was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_rpg
    @nomination = Nomination.new(nomination_type: 'RPG')
    render 'new_rpg'
  end

  def new_gotm
    @nomination = Nomination.new(nomination_type: 'GOTM')
    render 'new_gotm'
  end

  private

  def set_nomination
    @nomination = Nomination.find(params[:id])
  end

  def nomination_params
    params.fetch(:nomination, {})
  end
end
