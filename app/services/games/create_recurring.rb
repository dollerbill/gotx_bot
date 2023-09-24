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
      @atts = atts
    end

    def call
      raise NotImplementedError
    end

    private

    def create_game
      atts[:nominations_attributes][0][:theme] = theme
      atts[:nominations_attributes][0][:nomination_type] = nomination_type
      atts[:nominations_attributes][0][:winner] = winner
      @game = Game.create!(atts)
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
