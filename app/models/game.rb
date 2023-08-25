# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :nominations

  validate :presence_of_title

  def self.current_games
    {
      'GotM' => joins(:nominations).merge(Nomination.current_gotm_winners),
      'RPGotQ' => joins(:nominations).merge(Nomination.current_rpg_winners),
      'Retro Bit' => joins(:nominations).merge(Nomination.current_retro_winners)
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
