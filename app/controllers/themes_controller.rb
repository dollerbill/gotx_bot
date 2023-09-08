# frozen_string_literal: true

class ThemesController < ApplicationController
  before_action :set_theme, only: %i[show edit update destroy]

  def index
    @themes = if params[:search]&.presence
                ids = Theme.basic_search(title: params[:search]).map(&:id)
                Theme.where(id: ids).order(:creation_date).page(params[:page]).per(25)
              else
                Theme.order(:creation_date).page(params[:page]).per(25)
              end
  end

  def show; end

  def new
    @theme = Theme.new
  end

  def edit; end

  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to theme_url(@theme), notice: 'Theme was successfully created.' }
        format.json { render :show, status: :created, location: @theme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to theme_url(@theme), notice: 'Theme was successfully updated.' }
        format.json { render :show, status: :ok, location: @theme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:title, :description, :creation_date)
  end
end
