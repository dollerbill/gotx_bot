# frozen_string_literal: true

MODULES = [Gotx::Commands].freeze

bot = Gotx::Bot.initialize_bot

bot.ready do
  puts 'Bot is ready!'
end

bot.message do |event|
  puts "Received message: #{event.user.name} - #{event.message.content}"
end

ActiveRecord::Base.connection.execute('SELECT set_limit(0.6);')

MODULES.each { |mod| bot.include! mod }

bot.run :async
