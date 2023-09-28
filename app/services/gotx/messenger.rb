# frozen_string_literal: true

module Gotx
  class Messenger
    attr_reader :bot

    def initialize
      @bot = Gotx::Bot.initialize_bot
    end

    def self.reply
      new.bot.respond
    end

    def self.send_message(channel, message, member_id: nil)
      message = "<@#{member_id}> #{message}" if member_id
      new.bot.send_message(channel, message)
    end

    def self.mention(channel, user_id, message)
      new.bot.send_message(channel, "<@#{user_id}> #{message}")
    end
  end
end
