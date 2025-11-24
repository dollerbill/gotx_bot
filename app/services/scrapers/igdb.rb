# frozen_string_literal: true

module Scrapers
  class Igdb
    class GameNotFound < StandardError; end
    class AuthenticationError < StandardError; end

    TWITCH_AUTH_URL = 'https://id.twitch.tv/oauth2/token'
    IGDB_BASE_URL = 'https://api.igdb.com/v4'
    CLIENT_ID = ENV['TWITCH_CLIENT_ID']
    CLIENT_SECRET = ENV['TWITCH_CLIENT_SECRET']

    # Platform name to IGDB platform ID mapping
    # Users will select from these friendly names in Discord
    PLATFORM_IDS = {
      'NES' => 18,
      'SNES' => 19,
      'Nintendo 64' => 4,
      'GameCube' => 21,
      'Wii' => 5,
      'Wii U' => 41,
      'Nintendo Switch' => 130,
      'Game Boy' => 33,
      'Game Boy Color' => 22,
      'Game Boy Advance' => 24,
      'Nintendo DS' => 20,
      'Nintendo 3DS' => 37,
      'PlayStation' => 7,
      'PlayStation 2' => 8,
      'PlayStation 3' => 9,
      'PlayStation 4' => 48,
      'PlayStation 5' => 167,
      'PSP' => 38,
      'PS Vita' => 46,
      'Xbox' => 11,
      'Xbox 360' => 12,
      'Xbox One' => 49,
      'Xbox Series X|S' => 169,
      'Sega Genesis' => 29,
      'Sega Dreamcast' => 23,
      'Sega Saturn' => 32,
      'Sega Master System' => 64,
      'Sega Game Gear' => 35,
      'PC' => 6,
      'Arcade' => 52
    }.freeze

    attr_reader :atts, :igdb_game

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @atts = atts
    end

    def call
      # Hybrid approach: prioritize ID if provided, otherwise search by name
      @igdb_game = if atts['igdb_id'].present?
        fetch_by_id(atts['igdb_id'])
      elsif atts['game_name'].present?
        search_by_name(atts['game_name'], atts['platform'])
      else
        raise ArgumentError, 'Must provide either igdb_id or game_name'
      end

      raise GameNotFound, 'No game found matching criteria' unless igdb_game

      parse_game_data
    end

    private

    def fetch_by_id(igdb_id)
      query = <<~QUERY
        fields id, name, first_release_date, platforms.name, genres.name,
               involved_companies.company.name, involved_companies.developer,
               cover.url, screenshots.url, summary, alternative_names.name, alternative_names.comment;
        where id = #{igdb_id};
      QUERY

      response = make_request(query)
      games = JSON.parse(response.body)
      games.first
    end

    def search_by_name(name, platform = nil)
      platform_id = PLATFORM_IDS[platform]

      # Build search query with optional platform filter
      query = "search \"#{sanitize_search(name)}\";"

      # Filter: exclude DLC/editions (category 0 = main game)
      if platform_id
        query += " where platforms = (#{platform_id}) & category = 0;"
      else
        query += " where category = 0;"
      end

      query += <<~FIELDS
        fields id, name, first_release_date, platforms.name, genres.name,
               involved_companies.company.name, involved_companies.developer,
               cover.url, screenshots.url, summary, alternative_names.name, alternative_names.comment;
        limit 20;
      FIELDS

      response = make_request(query)
      games = JSON.parse(response.body)

      return nil if games.empty?

      # Fuzzy match to find best result
      find_best_match(games, name)
    end

    def find_best_match(games, search_name)
      # Try exact match first (case insensitive)
      exact_match = games.find { |g| g['name'].casecmp?(search_name) }
      return exact_match if exact_match

      # Try partial match
      partial_match = games.find { |g| g['name'].downcase.include?(search_name.downcase) }
      return partial_match if partial_match

      # Return first result (usually highest popularity)
      games.first
    end

    def parse_game_data
      {
        igdb_id: igdb_game['id'],
        title_usa: extract_regional_name('US') || igdb_game['name'],
        title_eu: extract_regional_name('EU') || igdb_game['name'],
        title_world: igdb_game['name'],
        title_jp: extract_regional_name('JP') || igdb_game['name'],
        title_other: nil,
        year: extract_year(igdb_game['first_release_date']),
        systems: extract_platforms,
        developer: extract_developer,
        genres: extract_genres,
        img_url: extract_image_url,
        time_to_beat: atts['time_to_beat'],
        nominations_attributes: [
          {
            user: atts['user'],
            theme: Theme.gotm.find_by('creation_date >=?', Date.current),
            description: atts['description'] || igdb_game['summary']
          }
        ]
      }
    end

    def extract_regional_name(region_code)
      return nil unless igdb_game['alternative_names']

      # IGDB alternative_names have a 'comment' field that sometimes includes region info
      regional_name = igdb_game['alternative_names'].find do |alt_name|
        alt_name['comment']&.upcase&.include?(region_code)
      end

      regional_name&.dig('name')
    end

    def extract_year(unix_timestamp)
      return nil unless unix_timestamp

      Time.at(unix_timestamp).year.to_s
    end

    def extract_platforms
      return [] unless igdb_game['platforms']

      igdb_game['platforms'].map { |p| p['name'] }
    end

    def extract_developer
      return nil unless igdb_game['involved_companies']

      # Find companies marked as developer
      developer = igdb_game['involved_companies'].find do |ic|
        ic['developer'] == true
      end

      developer&.dig('company', 'name')
    end

    def extract_genres
      return [] unless igdb_game['genres']

      igdb_game['genres'].map { |g| g['name'] }
    end

    def extract_image_url
      # Prefer screenshots over cover, and upgrade to higher resolution
      img_path = igdb_game.dig('screenshots', 0, 'url') || igdb_game.dig('cover', 'url')
      return nil unless img_path

      # Add https:// prefix and change size from t_thumb to t_720p
      "https:#{img_path.gsub('t_thumb', 't_720p')}"
    end

    def make_request(query)
      uri = URI("#{IGDB_BASE_URL}/games")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Client-ID'] = CLIENT_ID
      request['Authorization'] = "Bearer #{access_token}"
      request.body = query

      response = http.request(request)

      case response.code.to_i
      when 200
        response
      when 401
        # Token expired, refresh and retry once
        refresh_access_token
        request['Authorization'] = "Bearer #{access_token}"
        http.request(request)
      else
        raise GameNotFound, "IGDB API returned #{response.code}: #{response.body}"
      end
    end

    def access_token
      token_record = ApiToken.for_provider('igdb')

      # Get new token if none exists or if expired
      if token_record.nil? || token_record.expired?
        refresh_access_token
        token_record = ApiToken.for_provider('igdb')
      end

      token_record.access_token
    end

    def refresh_access_token
      uri = URI(TWITCH_AUTH_URL)
      params = {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        grant_type: 'client_credentials'
      }
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.post_form(uri, {})

      raise AuthenticationError, "Failed to authenticate with Twitch: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)

      # Twitch returns expires_in (seconds), convert to datetime
      expires_at = Time.current + data['expires_in'].seconds

      # Update or create token record
      token_record = ApiToken.for_provider('igdb')
      if token_record
        token_record.update!(
          access_token: data['access_token'],
          expires_at: expires_at
        )
      else
        ApiToken.create!(
          provider: 'igdb',
          access_token: data['access_token'],
          expires_at: expires_at
        )
      end
    end

    def sanitize_search(name)
      # Escape quotes for IGDB query
      name.gsub('"', '\\"')
    end
  end
end
