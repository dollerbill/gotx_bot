# frozen_string_literal: true

# == Schema Information
#
# Table name: completions
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime         not null
#  nomination_id :bigint
#  user_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
