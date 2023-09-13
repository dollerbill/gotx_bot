# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show redeem_points]

  def index
    @users = if params[:search]&.presence
               ids = User.fuzzy_search(params[:search]).map(&:id)
               User.where(id: ids).order(:name).page(params[:page]).per(25)
             else
               User.order(:name).page(params[:page]).per(25)
             end
  end

  def show
    @nominations = @user.nominations.gotm.page(params[:page]).per(10)
    @completions = @user.completions.joins(nomination: :theme).order(:creation_date).page(params[:page]).per(10)
  end

  def redeem_points
    Users::RedeemPoints.(@user, params['points'])

    redirect_to user_url(@user), notice: 'Points successfully redeemed.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
