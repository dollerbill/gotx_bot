# frozen_string_literal: true

class GameSerializer
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def as_json
    {
      name: game.preferred_name,
      year: game.year,
      system: game.systems.join(', '),
      systems: game.systems.join(', '),
      developer: game.developer,
      genre: game.genres.join(', '),
      genres: game.genres.join(', '),
      img_url: game.img_url,
      time_to_beat: game.time_to_beat,
      screenscraper_id: game.screenscraper_id,
      description: game.nominations.pluck('description').reject(&:blank?).first
    }
  end
end
