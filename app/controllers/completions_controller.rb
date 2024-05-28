# frozen_string_literal: true

class CompletionsController < ApplicationController
  include Pagy::Backend

  before_action :set_completion, only: %i[destroy update]
  before_action :set_nomination, only: %i[index]

  def index
    @pagy, @completions = pagy(@nomination.completions.joins(:user).order('users.name'))
  end

  def create
    user = User.find(params[:user_id])
    nomination = Nomination.find(params[:nomination_id])
    Nominations::Complete.call(user, nomination, true)
    redirect_to nomination_path(nomination), notice: "Completion recorded successfully for #{user.name}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to nomination_path(nomination), alert: e
  end

  def update
    if @completion.update(completion_params)
      redirect_to request.referer, notice: 'Achievements successfully recorded.'
    else
      redirect_to request.referer, alert: 'Error updating achievements.'
    end
  end

  def destroy
    ::Completions::Remove.(@completion)
    redirect_to user_path(@completion.user), notice: "Completion removed successfully for #{@completion.game.preferred_name}."
  end

  private

  def completion_params
    params.require(:completion).permit(:rpg_achievements)
  end

  def set_nomination
    @nomination = Nomination.find(params[:nomination_id])
  end

  def set_completion
    @completion = Completion.find(params[:id])
  end
end
