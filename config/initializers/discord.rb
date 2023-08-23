# frozen_string_literal: true

Dir[Rails.root.join('app/bot/commands/*')].each { |file| require_relative file }

MODULES = [GotxCommands].freeze

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['DISCORD_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID'],
  intents: %i[server_messages direct_messages],
  prefix: '/'
)

bot.ready do
  puts 'Bot is ready!'
end

bot.message do |event|
  puts "Received message: #{event.user.name} - #{event.message.content}"
end

ActiveRecord::Base.connection.execute('SELECT set_limit(0.6);')

MODULES.each do |mod|
  mod.register_application_commands(bot)
  bot.include! mod
end

bot.run :async
