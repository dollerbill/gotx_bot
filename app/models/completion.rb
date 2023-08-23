# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :nomination

  validates_uniqueness_of :user_id, scope: :nomination_id, message: 'has already completed this nomination'
end
