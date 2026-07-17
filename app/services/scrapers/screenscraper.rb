# frozen_string_literal: true

module Scrapers
  class Screenscraper
    class GameNotFound < StandardError; end
    class ApiUnavailable < StandardError; end

    BASE_URL = 'https://www.screenscraper.fr/api2/jeuInfos.php'

    attr_reader :atts, :game

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @atts = atts
    end

    def call
      parse_response(fetch)
    end

    private

    def fetch
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      response = http.get(url.request_uri)
      raise ApiUnavailable, "Screenscraper returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError => e
      raise ApiUnavailable, e.message
    end

    def url
      @url ||= begin
        raise GameNotFound, "Invalid screenscraper_id: #{atts['screenscraper_id'].inspect}" unless atts['screenscraper_id'].to_s.match?(/\A\d+\z/)

        URI("#{BASE_URL}?#{credential_params}&gameid=#{atts['screenscraper_id']}&media=wheel(wor)")
      end
    end

    def credential_params
      URI.encode_www_form(
        devid: ENV['SCREENSCRAPER_ID'],
        devpassword: ENV['SCREENSCRAPER_PASS'],
        softname: 'zzz',
        output: 'json',
        ssid: ENV['SCREENSCRAPER_DEV_ID'],
        sspassword: ENV['SCREENSCRAPER_DEV_PASS'],
        crc: ''
      )
    end

    def parse_response(response)
      raise ApiUnavailable if response.blank? || ['API closed', 'Erreur'].any? { |error| response.match?(error) }

      @game = JSON.parse(response)['response']['jeu']
      {
        screenscraper_id: game['id'],
        title_usa: region_name('us'),
        title_eu: region_name('eu'),
        title_world: region_name('wor'),
        title_jp: region_name('jp'),
        title_other: region_name('ss'),
        year: game['dates']&.map { |date| date['text']&.split('-')&.first }&.min,
        systems: game.dig('systeme', 'text'),
        developer: game.dig('developpeur', 'text'),
        genres: game['genres']&.first&.dig('noms')&.find { |g| g['langue'] == 'en' }&.dig('text'),
        img_url: image_url,
        time_to_beat: atts['time_to_beat'],
        nominations_attributes: [
          {
            user: atts['user'],
            theme: Theme.gotm.find_by('creation_date >=?', Date.current),
            description: atts['description'] || game['synopsis']&.find { |s| s['langue'] == 'en' }&.dig('text')
          }
        ]
      }
    end

    def region_name(region)
      game['noms']&.find { |n| n['region'] == region }&.dig('text')
    end

    def image_url
      return nil unless region

      "https://screenscraper.fr/image.php?gameid=#{game['id']}&region=#{region}&media=ss&maxwidth=640&maxheight=480"
    end

    def region
      game['medias']&.find { |m| m['type'] == 'ss' }&.dig('region')
    end
  end
end
