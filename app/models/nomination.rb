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

  enum nomination_type: {
    gotm: 'gotm',
    rpg: 'rpg',
    retro: 'retro'
  }

  def type
    NOMINATION_TYPE_NAMES[nomination_type]
  end
end
