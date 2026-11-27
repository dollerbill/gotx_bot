# frozen_string_literal: true

# == Schema Information
#
# Table name: completions
#
#  id               :bigint           not null, primary key
#  completed_at     :datetime         not null
#  nomination_id    :bigint
#  user_id          :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rpg_achievements :boolean          default(FALSE)
#
class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :nomination
  delegate :game, :theme, to: :nomination

  scope :previous_completions, ->(type) { joins(nomination: :theme).merge(Theme.most_recent(type)) }

  validates_uniqueness_of :user_id, scope: :nomination_id, message: 'has already completed this nomination'
  validate :rpg_achievements_for_rpgotq
  after_update :award_achievement_points, if: -> { saved_change_to_rpg_achievements?(from: false, to: true) }

  COMPLETION_POINTS = {
    'gotm' => 1,
    'goty' => 1,
    'retro' => 0.5,
    'gotwoty' => 0.5,
    'rpg' => 1
  }.freeze

  RPG_ACHIEVEMENT_POINTS = 2

  def current_rpg_winner?
    Nomination.current_rpg_winners.exists?(nomination_id)
  end

  def rpg_achievements_for_rpgotq
    return unless rpg_achievements

    if !nomination.rpg?
      errors.add(:rpg_achievements, 'can only be set for RPG nominations')
    elsif will_save_change_to_rpg_achievements? && !current_rpg_winner?
      errors.add(:rpg_achievements, 'can only be set for the current RPGotQ')
    end
  end

  private

  def award_achievement_points
    Users::AddPoints.(user, RPG_ACHIEVEMENT_POINTS)
  end
end
