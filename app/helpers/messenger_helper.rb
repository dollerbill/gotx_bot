# frozen_string_literal: true

module MessengerHelper
  def available_channels
    [
      ['GotM Discussion', ENV['GOTM_DISCUSSION_CHANNEL_ID']],
      ['GotW Discussion', ENV['GOTW_DISCUSSION_CHANNEL_ID']],
      ['RPGotQ', ENV['RPGOTQ_CHANNEL_ID']]
    ]
  end
end
