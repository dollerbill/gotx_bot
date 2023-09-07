# frozen_string_literal: true

class Theme < ApplicationRecord
  has_many :nominations

  scope :current_month, lambda {
    where(creation_date: Date.current.beginning_of_month..Date.current.end_of_month)
      .where.not('title ILIKE ?', '%Retro%')
  }
  scope :current_quarter, -> { where(creation_date: Date.current.beginning_of_quarter..Date.current.end_of_quarter) }
  scope :current_gotm, -> { gotm.last }

  enum nomination_type: {
    gotm: 'gotm',
    rpg: 'rpg',
    retro: 'retro',
    goty: 'goty'
  }
end
