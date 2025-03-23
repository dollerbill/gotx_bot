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
      system: game.system,
      developer: game.developer,
      genre: game.genre,
      img_url: game.img_url,
      time_to_beat: game.time_to_beat,
      screenscraper_id: game.screenscraper_id
    }
  end
end
