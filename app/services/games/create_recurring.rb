# frozen_string_literal: true

module Games
  class CreateRecurring
    ANNOUNCEMENT_CHANNEL_ID = ENV['ANNOUNCEMENT_CHANNEL_ID'].freeze
    GOTX_ROLE_ID = ENV['GOTX_ROLE_ID'].freeze

    attr_reader :atts, :game

    def self.call(atts)
      new(atts).call
    end

    def initialize(atts)
      @atts = atts.merge(user_id: 12)
    end

    def call
      raise NotImplementedError
    end

    private

    def find_or_create_game
      nominations_attributes = { user_id: atts[:user_id], theme:, nomination_type:, winner: }
      @game = if (found_game = Game.find_by(screenscraper_id: atts[:screenscraper_id]))
                found_game.tap { |game| game.nominations.create!(nominations_attributes) }
              else
                scraped_atts = ::Scrapers::Screenscraper.(atts).tap do |scraped|
                  scraped[:nominations_attributes] = [nominations_attributes.merge({ description: scraped[:nominations_attributes][0][:description] })]
                end
                Game.create!(scraped_atts)
              end
    end

    def theme
      raise NotImplementedError
    end

    def nomination_type
      raise NotImplementedError
    end

    def bot
      @bot ||= Gotx::Bot.initialize_bot
    end

    def post_announcement
      bot.channel(ANNOUNCEMENT_CHANNEL_ID).send_message(message)
      bot.channel(ANNOUNCEMENT_CHANNEL_ID).send_embed do |embed|
        embed.description = description
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: @game.img_url)
      end
    end

    def description
      raise NotImplementedError
    end

    def channel
      raise NotImplementedError
    end

    def message
      raise NotImplementedError
    end

    def winner
      nil
    end
  end
end
