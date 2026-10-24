# frozen_string_literal: true

module Scrapers
  class ScreenscraperSearch < Screenscraper
    SEARCH_URL = 'https://www.screenscraper.fr/api2/jeuRecherche.php'
    MAX_RESULTS = 10

    private

    def url
      @url ||= URI("#{SEARCH_URL}?#{credential_params}&#{URI.encode_www_form(recherche: atts['name'])}")
    end

    def parse_response(response)
      raise ApiUnavailable if response.blank? || response.match?('API closed')

      games = JSON.parse(response).dig('response', 'jeux') || []
      # An empty search returns a single blank game rather than an empty list
      games.select { |game| game['id'].present? }.first(MAX_RESULTS).map do |game|
        {
          screenscraper_id: game['id'],
          title: title(game),
          system: game.dig('systeme', 'text'),
          year: game['dates']&.map { |date| date['text']&.split('-')&.first }&.min
        }
      end
    rescue JSON::ParserError
      raise ApiUnavailable
    end

    def title(game)
      names = game['noms'] || []
      %w[us wor eu jp ss].each do |region|
        name = names.find { |n| n['region'] == region }&.dig('text')
        return name if name.present?
      end
      names.first&.dig('text')
    end
  end
end
