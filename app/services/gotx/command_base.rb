# frozen_string_literal: true

module Gotx
  module CommandBase
    def self.included(base)
      base.extend Discordrb::Commands::CommandContainer
      base.extend Discordrb::EventContainer
    end

    EMOJI = 1042504406064701500

    CHANNELS = {
      dev: ENV['DEV_CHANNEL_ID'],
      rank: ENV['RANK_CHANNEL_ID'],
      gotx: ENV['GOTX_CHANNEL_ID']
    }.freeze
  end
end
