# frozen_string_literal: true

module Users
  class Update
    attr_reader :user, :previous_atts, :previous_admin, :atts

    def self.call(user, atts)
      new(user, atts).call
    end

    POINT_ATTS = %w[current_points earned_points redeemed_points premium_points].freeze

    def initialize(user, atts)
      @user = user
      @previous_atts = user.attributes.slice(*POINT_ATTS)
      @previous_admin = user.admin
      @atts = atts
    end

    def call
      notify if update
    end

    private

    def update
      user.assign_attributes(atts)
      user.save if user.changed?
    end

    def notify
      msg = "User #{user.name} updated:"
      previous_atts.each do |k, v|
        new_value = user.send(k)
        next if new_value == v.to_f

        msg += "\n#{k.humanize} updated from #{v} to #{user.send(k)}"
      end

      msg += "\n:warning: Admin #{user.admin ? 'GRANTED' : 'REVOKED'}" if user.admin != previous_admin

      bot.send_message(ENV['GOTX_CHANNEL_ID'], msg)
    end

    def bot
      @bot ||= ::Gotx::Bot.initialize_bot
    end
  end
end
