# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id               :bigint           not null, primary key
#  title_usa        :string
#  title_eu         :string
#  title_jp         :string
#  title_world      :string
#  title_other      :string
#  year             :string
#  system           :string
#  developer        :string
#  genre            :string
#  img_url          :string
#  time_to_beat     :integer
#  screenscraper_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Game < ApplicationRecord
  has_many :nominations

  validate :presence_of_title

  accepts_nested_attributes_for :nominations

  def self.current_games
    {
      'GotM' => joins(:nominations).merge(Nomination.current_gotm_winners),
      'RPGotQ' => joins(:nominations).merge(Nomination.current_rpg_winners),
      'Retro Bit' => joins(:nominations).merge(Nomination.current_retro_winners)
    }
  end

  def self.current_goty_games
    {
      'GotY' => joins(:nominations).merge(Nomination.current_goty_winners.goty),
      'GotWotY' => joins(:nominations).merge(Nomination.current_goty_winners.gotwoty)
    }
  end

  def presence_of_title
    return if preferred_name

    errors.add(:base, 'Game must have a title')
  end

  def all_names
    "#{title_usa} #{title_eu} #{title_jp} #{title_world}".strip
  end

  def preferred_name
    title_usa || title_world || title_eu || title_jp || title_other
  end
end
