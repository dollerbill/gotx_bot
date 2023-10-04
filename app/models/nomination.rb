# frozen_string_literal: true

class Nomination < ApplicationRecord
  NOMINATION_TYPE_NAMES = {
    'gotm' => 'GotM',
    'rpg' => 'RPGotQ',
    'retro' => 'RetroBits',
    'goty' => 'GotY'
  }.freeze

  belongs_to :game, dependent: :destroy
  belongs_to :user
  belongs_to :theme
  has_many :completions

  scope :winners, -> { where(winner: true) }
  scope :current_retro_winner, -> { retro.order(created_at: :desc).limit(1) }
  scope :current_gotm_winners, -> { winners.gotm.joins(:theme).merge(Theme.current_gotm) }
  scope :current_rpg_winners, -> { winners.rpg.joins(:theme).merge(Theme.current_rpg) }
  scope :current_nominations, -> { where(theme_id: Theme.current_gotm.pluck(:id) + Theme.current_rpg.pluck(:id)) }
  scope :previous_winners, ->(type) { winners.joins(:theme).merge(Theme.most_recent(type)) }

  enum nomination_type: {
    gotm: 'gotm',
    rpg: 'rpg',
    retro: 'retro',
    goty: 'goty'
  }

  def self.current_time
    Time.now.in_time_zone('Eastern Time (US & Canada)')
  end

  def self.nominations_open
    current_time.change(day: 17, hour: 20, min: 0, sec: 0)
  end

  def self.nominations_open_est
    nominations_open.in_time_zone('EST').strftime('%H:%M %Z %m-%d-%Y')
  end

  def self.nominations_close
    current_time.change(day: 24, hour: 20, min: 0, sec: 0)
  end

  def self.open?
    current_time >= nominations_open && current_time <= nominations_close
  end

  def self.current_winners
    current_gotm_winners + current_rpg_winners + current_retro_winner
  end

  def type
    NOMINATION_TYPE_NAMES[nomination_type]
  end
end
