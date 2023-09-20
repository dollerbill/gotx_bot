# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :nomination

  scope :previous_completions, ->(type) { joins(nomination: :theme).merge(Theme.most_recent(type)) }

  validates_uniqueness_of :user_id, scope: :nomination_id, message: 'has already completed this nomination'
end
