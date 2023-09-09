# frozen_string_literal: true

class Theme < ApplicationRecord
  before_create :set_retrobit_template

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

  def set_retrobit_template
    date = Date.today
    self.creation_date ||= date
    self.title ||= "Retro Bits #{date}"
    self.description ||= "Retro Bits Theme - #{date.cweek.ordinalize} week of #{date.year}"
    self.nomination_type ||= 'retro'
  end
end
