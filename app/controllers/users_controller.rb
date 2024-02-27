# frozen_string_literal: true

class UsersController < ApplicationController
  include Helpers::FuzzySearchHelper
  include Pagy::Backend

  before_action :set_user, only: %i[show edit update redeem_points]

  def index
    set_search_limit

    users = if params[:search]&.presence
              ids = User.fuzzy_search(params[:search]).map(&:id)
              User.where(id: ids).order(:name)
            else
              User.order(:name)
            end
    @pagy, @users = pagy(users)
  end

  def show
    @pagy_nominations, @nominations = pagy(@user.nominations, page_param: :page_nominations)
    completions = @user.completions.joins(nomination: :theme).order(:creation_date)
    @pagy_completions, @completions = pagy(completions, page_param: :page_completions)
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
    @pagy, @users = pagy(User.previous_finishers(@type))
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:current_points, :earned_points, :redeemed_points, :premium_points)
  end
end
