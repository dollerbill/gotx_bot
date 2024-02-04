# frozen_string_literal: true

class CompletionsController < ApplicationController
  before_action :set_completion, only: %i[destroy]

  def create
    user = User.find(params[:user_id])
    nomination = Nomination.find(params[:nomination_id])
    Nominations::Complete.call(user, nomination, true)
    redirect_to nomination_path(nomination), notice: "Completion recorded successfully for #{user.name}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to nomination_path(nomination), notice: e
  end

  def destroy
    ::Completions::Remove.(@completion)
    redirect_to user_path(@completion.user), notice: "Completion removed successfully for #{@completion.game.preferred_name}."
  end

  private

  def set_completion
    @completion = Completion.find(params[:id])
  end
end
