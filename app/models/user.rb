# frozen_string_literal: true

class User < ApplicationRecord
  has_many :completions
  has_many :nominations

  scope :scores, -> { where.not(name: nil).order(earned_points: :desc) }
  scope :top10, -> { scores.limit(10).map(&:name) }
end
