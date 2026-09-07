# frozen_string_literal: true

module Memberships
  class UpdateSubscribers
    GOTX_CHANNEL_ID = ENV['GOTX_CHANNEL_ID'].freeze
    SERVER_ID = ENV['DISCORD_SERVER_ID'].freeze
    PREMIUM_ROLES = ['SUPPORTER', 'CHAMPION', 'LEGEND', 'RH Supporter', 'RH Champion', 'RH Legend'].freeze
    MEMBER_PAGE_LIMIT = 1000
    MemberData = Struct.new(:id, :name)

    def self.call
      new.call
    rescue StandardError => e
      Sentry.capture_exception(e)
      raise
    end

    def call
      ActiveRecord::Base.transaction do
        remove_canceled_subscribers
        update_new_subscribers
      end
    end

    private

    def remove_canceled_subscribers
      removed_users = []
      User.premium.each do |user|
        member = bot.member(SERVER_ID, user.discord_id)
        next if member.nil?
        next if (member.roles.map(&:name) & PREMIUM_ROLES).any?

        ::Users::UpdatePremiumStatus.(user)
        removed_users << user
      rescue Discordrb::Errors::NoPermission, StandardError => e
        Rails.logger.error("Failed to fetch member #{user.discord_id}: #{e.message} to update subscriber")
      end

      notify("Users: #{removed_users.map(&:name).join(', ')} are no longer premium subscribers.") if removed_users.any?
    end

    def update_new_subscribers
      added_users = []
      premium_roles = bot.server(SERVER_ID).roles.select { |role| role.name.in?(PREMIUM_ROLES) }
      roles_by_id = premium_roles.index_by { |role| role.id.to_s }

      fetch_guild_members.each do |member_data|
        role = member_data['roles'].filter_map { |id| roles_by_id[id.to_s] }.first
        next if role.nil?

        user = Users::FindOrCreate.(MemberData.new(member_data['user']['id'], member_data['user']['username']))
        membership_level = membership_mapping(role)
        next if user.premium_subscriber == membership_level

        Users::UpdatePremiumStatus.(user, membership_level)
        added_users << user
      end

      notify("Users: #{added_users.map(&:name).join(', ')} have become premium subscribers.") if added_users.any?
    end

    def fetch_guild_members
      members = []
      after = nil

      loop do
        page = JSON.parse(Discordrb::API::Server.resolve_members(bot.token, SERVER_ID, MEMBER_PAGE_LIMIT, after))
        break if page.empty?

        members.concat(page)
        break if page.size < MEMBER_PAGE_LIMIT

        after = page.last['user']['id']
      end

      members
    end

    def bot
      @bot ||= Gotx::Bot.initialize_bot
    end

    def notify(message)
      bot.send_message(ENV['GOTX_CHANNEL_ID'], message)
    end

    def membership_mapping(role)
      case role.name
      when 'SUPPORTER', 'RH Supporter'
        'supporter'
      when 'CHAMPION', 'RH Champion'
        'champion'
      when 'LEGEND', 'RH Legend'
        'legend'
      end
    end
  end
end
