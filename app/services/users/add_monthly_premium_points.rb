# frozen_string_literal: true

module Users
  class AddMonthlyPremiumPoints
    def self.call
      new.call
    end

    def call
      User.transaction do
        update_points
        notify
      end
    end

    def update_points
      User.supporter.update_all('current_points = current_points + 1, premium_points = premium_points + 1')
      User.champion.update_all('current_points = current_points + 2, premium_points = premium_points + 2')
      User.legend.update_all('current_points = current_points + 3, premium_points = premium_points + 3')
    end

    def notify
      time = Time.now.in_time_zone('EST').strftime('%H:%M %Z %m-%d-%Y')
      message_bot = Gotx::Bot.initialize_bot
      message_bot.send_message(ENV['GOTX_CHANNEL_ID'], "Monthly premium points updated at #{time}")
    end
  end
end
