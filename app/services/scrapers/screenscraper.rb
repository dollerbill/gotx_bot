# frozen_string_literal: true

module Scrapers
  class Screenscraper
    class GameNotFound < StandardError; end

    DEV_ID = ENV['SCREENSCRAPER_ID']
    DEV_PASS = ENV['SCREENSCRAPER_PASS']
    SS_ID = ENV['SCREENSCRAPER_DEV_ID']
    SS_PASS = ENV['SCREENSCRAPER_DEV_PASS']
    SCREENSCRAPER_BASE_URL = "https://www.screenscraper.fr/api2/jeuInfos.php?devid=#{DEV_ID}&devpassword=#{DEV_PASS}&softname=zzz&output=json&ssid=#{SS_ID}&sspassword=#{SS_PASS}&crc=".freeze

    attr_reader :atts, :game

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @atts = atts
    end

    def call
      parse_response(Net::HTTP.get(url))
    end

    private

    def url
      URI("#{SCREENSCRAPER_BASE_URL}&gameid=#{atts['screenscraper_id']}&media=wheel(wor)")
    end

    def parse_response(response)
      raise GameNotFound if ['API closed', 'Erreur'].any? { |error| response.match?(error) } || response.blank?

      @game = JSON.parse(response)['response']['jeu']
      {
        screenscraper_id: game['id'],
        title_usa: region_name('us'),
        title_eu: region_name('eu'),
        title_world: region_name('wor'),
        title_jp: region_name('jp'),
        title_other: region_name('ss'),
        year: game['dates']&.map { |date| date['text']&.split('-')&.first }&.min,
        system: game.dig('systeme', 'text'),
        developer: game.dig('developpeur', 'text'),
        genre: game['genres']&.first&.dig('noms')&.find { |g| g['langue'] == 'en' }&.dig('text'),
        img_url: image_url,
        nominations_attributes: [
          {
            user_id: atts['user_id'],
            theme: Theme.current_gotm,
            description: atts['description'] || game['synopsis'].find { |s| s['langue'] == 'en' }&.dig('text')
          }
        ]
      }
    end

    def region_name(region)
      game['noms'].find { |n| n['region'] == region }&.dig('text')
    end

    def image_url
      "https://screenscraper.fr/image.php?gameid=#{game['id']}&region=#{region}&media=ss&maxwidth=640&maxheight=480"
    end

    def region
      game['medias'].find { |m| m['type'] == 'ss' }['region']
    end
  end
end
