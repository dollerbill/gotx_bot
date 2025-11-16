# frozen_string_literal: true

module Gotx
  class Bot
    SERVER = { server_id: ENV['DISCORD_SERVER_ID'] }.freeze

    def self.initialize_bot
      Discordrb::Commands::CommandBot.new(
        token: ENV['DISCORD_TOKEN'],
        client_id: ENV['DISCORD_CLIENT_ID'],
        intents: %i[server_messages direct_messages server_members],
        prefix: '/'
      )
    end
  end
end
