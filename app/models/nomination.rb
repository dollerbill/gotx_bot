# frozen_string_literal: true

class Nomination < ApplicationRecord
  NOMINATION_TYPE_NAMES = {
    'gotm' => 'GotM',
    'rpg' => 'RPGotQ',
    'retro' => 'RetroBits'
  }.freeze

  belongs_to :game
  belongs_to :user
  belongs_to :theme
  has_many :completions

  scope :winners, -> { where(winner: true) }
  scope :current_retro_winners, -> { retro.order(created_at: :desc).limit(1) }
  scope :current_gotm_winners, -> { winners.gotm.joins(:theme).merge(Theme.current_month) }
  scope :current_rpg_winners, -> { winners.rpg.joins(:theme).merge(Theme.current_quarter) }

  enum nomination_type: {
    gotm: 'gotm',
    rpg: 'rpg',
    retro: 'retro'
  }

  def self.current_winners
    current_gotm_winners + current_rpg_winners + current_retro_winners
  end

  def type
    NOMINATION_TYPE_NAMES[nomination_type]
  end
end
