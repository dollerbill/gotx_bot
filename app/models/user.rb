# frozen_string_literal: true

class User < ApplicationRecord
  has_many :completions
  has_many :nominations
  has_many :streaks
  has_many :subscriptions

  scope :scores, -> { where.not(name: nil).order(earned_points: :desc) }
  scope :top10, -> { scores.limit(10) }
  scope :premium, -> { where.not(premium_subscriber: nil) }
  scope :previous_finishers, ->(type) { joins(:completions).merge(Completion.previous_completions(type)).distinct }

  enum premium_subscriber: {
    supporter: 'supporter',
    champion: 'champion',
    legend: 'legend'
  }

  validates_uniqueness_of :discord_id, message: 'already exists with this Discord ID', allow_nil: true

  def current_completions
    current_ids = Nomination.current_winners.pluck(:id)
    completions.where(nomination_id: current_ids)&.map(&:nomination)
  end

  def completion_streak
    return 0 unless completions.any?

    themes = Theme.gotm.where('creation_date <= ?', Date.today).order(creation_date: :desc)
    streak = 0
    starting_theme = if completed?(themes.first)
                       themes.first
                     elsif completed?(themes.second)
                       themes.second
                     end
    themes.drop_while { |theme| theme != starting_theme }.each do |theme|
      break unless completed?(theme)

      streak += 1
    end

    streak
  end

  private

  def completed?(theme)
    completions.joins(:nomination).where(nominations: { theme: }).exists?
  end
end
