# frozen_string_literal: true

class StreaksController < ApplicationController
  before_action :set_streak, only: :show

  def index
    @active_streaks = Streak.active.order(streak_count: :desc)
    @new_streaks = Streak.newly_started
    @broken_streaks = Streak.broken
  end

  def show; end

  private

  def set_streak
    @streak = Streak.find(params[:id])
  end
end
