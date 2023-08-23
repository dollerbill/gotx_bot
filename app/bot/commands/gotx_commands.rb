# frozen_string_literal: true

module GotxCommands
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  SERVER = { server_id: ENV['DISCORD_SERVER_ID'] }.freeze

  def self.register_application_commands(bot)
  end
end
