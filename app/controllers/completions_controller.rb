# frozen_string_literal: true

class CompletionsController < ApplicationController
  def create
    user = User.find(params[:user_id])
    nomination = Nomination.find(params[:nomination_id])
    Nominations::Complete.call(user, nomination, true)
    redirect_to nomination_path(nomination), notice: "Completion recorded successfully for #{user.name}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to nomination_path(nomination), notice: e
  end
end
