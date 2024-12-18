# frozen_string_literal: true

# == Schema Information
#
# Table name: nominations
#
#  id              :bigint           not null, primary key
#  nomination_type :string           default("gotm"), not null
#  description     :string
#  winner          :boolean          default(FALSE)
#  game_id         :bigint
#  user_id         :bigint
#  theme_id        :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Nomination < ApplicationRecord
  include NominationTypes

  NOMINATION_TYPE_NAMES = {
    'gotm' => 'GotM',
    'rpg' => 'RPGotQ',
    'retro' => 'RetroBits',
    'goty' => 'GotY'
  }.freeze

  belongs_to :game
  belongs_to :user
  belongs_to :theme
  has_many :completions

  scope :winners, -> { where(winner: true) }
  scope :current_retro_winners, -> { retro.order(created_at: :desc).limit(1) }
  scope :current_gotm_winners, -> { winners.gotm.joins(:theme).merge(Theme.current_gotm) }
  scope :current_goty_winners, -> { where(theme_id: Theme.playable_goty.pluck(:id)) }
  scope :current_rpg_winners, -> { winners.rpg.joins(:theme).merge(Theme.current_rpg) }
  scope :current_nominations, -> { where(theme_id: Theme.current_gotm_theme.pluck(:id) + Theme.current_rpg.pluck(:id)) }
  scope :previous_winners, ->(type) { winners.joins(:theme).merge(Theme.most_recent(type)) }

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

  def self.begun?
    current_time >= nominations_open
  end

  def self.current_winners
    current_gotm_winners + current_rpg_winners + current_retro_winners + current_goty_winners
  end

  def type
    NOMINATION_TYPE_NAMES[nomination_type]
  end
end
