# frozen_string_literal: true

class ThemesController < ApplicationController
  include Pagy::Backend

  before_action :set_theme, only: %i[show edit update destroy]

  def index
    themes = Theme.all

    themes = themes.where(nomination_type: params[:nomination_type]) if params[:nomination_type]&.presence

    if params[:search]&.presence
      ids = themes.basic_search(title: params[:search]).map(&:id)
      themes = themes.where(id: ids)
    end

    @pagy, @themes = pagy(themes.order(:creation_date))
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
