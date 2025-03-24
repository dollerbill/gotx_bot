# frozen_string_literal: true

class Api::V1::GamesController < ApiController
  def current
    serialized_games = Game.current_games.transform_values do |v|
      v.map { |game| GameSerializer.new(game).as_json }
    end

    render json: serialized_games, status: :ok
  end
end
