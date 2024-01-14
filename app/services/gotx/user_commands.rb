# frozen_string_literal: true

module Gotx
  module UserCommands
    include CommandBase

    application_command(:standing) do |event|
      user = ::Users::FindOrCreate.(event.user)
      rank = User.scores.pluck(:earned_points).find_index(user.earned_points) + 1
      event.respond(ephemeral: true, content: <<~RESPONSE)
        You've earned #{user.earned_points} GotX points which puts you in #{rank.ordinalize} place on the leaderboard.
        You have #{user.current_points} total points currently available to spend.
      RESPONSE
    end

    application_command(:leaderboard) do |event|
      msg = "**GotX Leaderboard**\n```"
      User.top10.each_with_index { |user, index| msg += "\n#{index + 1}. #{user.name} - #{user.earned_points}" }
      msg += "\n```"
      event.respond(content: msg)
    end

    application_command(:membership) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(member)
      event.respond(content: 'Update premium membership status:') do |_, view|
        view.row do |r|
          r.button(label: 'Membership status', style: :secondary, custom_id: "#{user.id}_premium_member_status", emoji: 1042504406064701500)
          r.button(label: 'Remove membership', style: :danger, custom_id: "#{user.id}_update_premium_member_remove", emoji: 1042504406064701500)
          r.button(label: 'Add membership', style: :success, custom_id: "#{user.id}_update_premium_member_add", emoji: 1042504406064701500)
        end
      end
    end

    application_command(:redeem_points) do |event|
      merch_manager = event.bot.user(ENV['MERCH_MANAGER_USER_ID'])
      msg = "Hey #{merch_manager.mention}, #{event.user.mention} wants to redeem points for RH merch!"
      msg += "\n> #{event.options['swag']}" if event.options['swag']
      event.bot.channel(CHANNELS[:gotx]).send_message(msg)
      event.respond(content: I18n.t('points.redeem'), ephemeral: true)
    end

    application_command(:streak) do |event|
      member = event.bot.user(event.user)
      user = ::Users::FindOrCreate.(member)
      streak = user.completion_streak
      event.respond(content: I18n.t('users.streak.format', name: member.mention, count: streak))
    end

    button(custom_id: /\d_premium_member_status/) do |event|
      user = User.find(event.interaction.button.custom_id.split('_')[0])
      membership_status = user.premium_subscriber
      next event.update_message(content: "#{user.name} is not a premium subscriber.") unless membership_status

      event.update_message(content: "#{user.name} is a #{membership_status.capitalize} level subscriber.")
    end

    button(custom_id: /\d_update_premium_member_/) do |event|
      atts = event.interaction.button.custom_id.split('_update_premium_member_')
      user = User.find(atts[0])
      update = atts[1] == 'add'
      unless update
        ::Users::UpdatePremiumStatus.(user, nil)
        member = event.bot.user(user.discord_id)
        event.bot.channel(CHANNELS[:rank]).send_message("#{member.mention} is no longer a premium subscriber.")

        next event.update_message(content: "#{user.display_name} is no longer a premium member.")
      end

      event.update_message(content: 'Update membership level:') do |_, view|
        view.row do |row|
          row.button(label: 'Supporter', style: :danger, custom_id: "#{user.id}_add_premium_membership_supporter", emoji: 1042504406064701500)
          row.button(label: 'Champion', style: :success, custom_id: "#{user.id}_add_premium_membership_champion", emoji: 1042504406064701500)
          row.button(label: 'Legend', style: :primary, custom_id: "#{user.id}_add_premium_membership_legend", emoji: 1042504406064701500)
        end
      end
    end

    button(custom_id: /\d_add_premium_membership_/) do |event|
      atts = event.interaction.button.custom_id.split('_add_premium_membership_')
      user = User.find(atts[0])
      status = atts[1]
      member = event.bot.user(user.discord_id)
      ::Users::UpdatePremiumStatus.(user, status)
      event.update_message(content: "#{user.name} has been upgraded to #{status.capitalize} status.")
      event.bot.channel(CHANNELS[:rank]).send_message("#{member.mention} is now a #{status.capitalize} subscriber.")
    end
  end
end
