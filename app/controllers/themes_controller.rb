# frozen_string_literal: true

class ThemesController < ApplicationController
  include Pagy::Backend

  before_action :set_theme, only: %i[show edit update destroy]

  def index
    themes = if params[:search]&.presence
               ids = Theme.basic_search(title: params[:search]).map(&:id)
               Theme.where(id: ids).order(:creation_date)
             else
               Theme.order(:creation_date)
             end
    @pagy, @themes = pagy(themes)
  end

  def show; end

  def new
    @theme = Theme.new
  end

  def edit; end

  def create
    @theme = Theme.new(theme_params)

    if @theme.save
      redirect_to theme_url(@theme), notice: 'Theme was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @theme.update(theme_params)
      redirect_to theme_url(@theme), notice: 'Theme was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:title, :description, :creation_date, :nomination_type)
  end
end
