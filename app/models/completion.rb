# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :nomination
  delegate :game, :theme, to: :nomination

  scope :previous_completions, ->(type) { joins(nomination: :theme).merge(Theme.most_recent(type)) }

  validates_uniqueness_of :user_id, scope: :nomination_id, message: 'has already completed this nomination'

  COMPLETION_POINTS = {
    'gotm' => 1,
    'goty' => 1,
    'retro' => 0.5,
    'gotwoty' => 0.5,
    'rpg' => 1
  }.freeze
end
