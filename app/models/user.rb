# frozen_string_literal: true

class User < ApplicationRecord
  has_many :completions
  has_many :nominations

  scope :scores, -> { where.not(name: nil).order(earned_points: :desc) }
  scope :top10, -> { scores.limit(10) }
  scope :premium, -> { where.not(premium_subscriber: nil) }

  enum premium_subscriber: {
    supporter: 'supporter',
    champion: 'champion',
    legend: 'legend'
  }

  validates_uniqueness_of :discord_id, message: 'already exists with this Discord ID', allow_nil: true

  def current_completions
    current_ids = Nomination.current_winners.map(&:id)
    completions.where(nomination_id: current_ids)
  end
end
