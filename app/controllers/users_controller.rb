# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update redeem_points]

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

  def edit; end

  def update
    result = Users::Update.(@user, user_params)
    if result
      redirect_to @user, notice: 'User was successfully updated.'
    else
      redirect_to edit_user_path(@user), notice: 'User not updated, provided attributes match their current values.'
    end
  end

  def redeem_points
    Users::RedeemPoints.(@user, params['points'])

    redirect_to user_url(@user), notice: 'Points successfully redeemed.'
  end

  def previous_finishers
    @type = params[:type] || 'gotm'
    @users = User.previous_finishers(@type).page(params[:page]).per(50)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:current_points, :earned_points, :redeemed_points, :premium_points)
  end
end
