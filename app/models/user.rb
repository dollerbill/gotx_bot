# frozen_string_literal: true

class User < ApplicationRecord
  has_many :completions
  has_many :nominations

  scope :scores, -> { where.not(name: nil).order(earned_points: :desc) }
  scope :top10, -> { scores.limit(10).map(&:name) }

  def current_completions
    current_ids = Nomination.current_winners.map(&:id)
    completions.where(nomination_id: current_ids)
  end
end
