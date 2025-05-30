# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id              :bigint           not null, primary key
#  creation_date   :date             not null
#  title           :string           not null
#  description     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nomination_type :string           default("gotm")
#
class Theme < ApplicationRecord
  include NominationTypes

  NOMINATION_TIME = {
    'gotm' => 'month',
    'retro' => 'week',
    'rpg' => 'quarter',
    'goty' => 'year'
  }.freeze

  before_create :set_retrobit_template

  has_many :nominations
  has_many :completions, through: :nominations

  scope :current_goty, -> { current_theme_for('goty') }
  scope :current_rpg, -> { current_theme_for('rpg') }
  scope :current_gotm, -> { current_theme_for('gotm') }
  scope :current_retro, -> { current_theme_for('retro') }
  scope :playable_goty, lambda {
    where(nomination_type: %w[goty gotwoty]).where('title LIKE ?', "%#{Date.current.last_year.year}%")
  }
  scope :most_recent, ->(type) { where(id: most_recent_id_for(type)) }

  def set_retrobit_template
    date = Date.today
    self.creation_date ||= date
    self.title ||= "Retro Bits #{date}"
    self.description ||= "Retro Bits Theme - #{date.cweek.ordinalize} week of #{date.year}"
  end

  def self.current_gotm_theme
    if Nomination.begun?
      gotm.where(creation_date: Date.current.next_month.beginning_of_month..Date.current.next_month.end_of_month)
    else
      gotm.where(creation_date: Date.current.beginning_of_month..Date.current.end_of_month)
    end
  end

  def self.current_theme_for(nomination_type)
    where(nomination_type:)
      .where(
        creation_date: Date.current.public_send(
          "beginning_of_#{NOMINATION_TIME[nomination_type]}"
        )..Date.current.public_send("end_of_#{NOMINATION_TIME[nomination_type]}")
      )
  end

  def self.most_recent_id_for(nomination_type)
    where(nomination_type:)
      .where(
        'creation_date <= ?', Date.current.public_send("last_#{NOMINATION_TIME[nomination_type]}")
                                  .public_send("beginning_of_#{NOMINATION_TIME[nomination_type]}")
      )
      .order(creation_date: :desc)
      .limit(1)
      .ids
  end
end
