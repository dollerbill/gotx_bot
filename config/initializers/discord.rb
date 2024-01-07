# frozen_string_literal: true

MODULES = [Gotx::GameCommands, Gotx::UserCommands].freeze

bot = Gotx::Bot.initialize_bot

bot.ready do
  puts 'Bot is ready!'
end

bot.message do |event|
  puts "Received message: #{event.user.name} - #{event.message.content}"
end

MODULES.each { |mod| bot.include! mod }

bot.run :async
