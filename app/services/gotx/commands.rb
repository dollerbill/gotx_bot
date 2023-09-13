# frozen_string_literal: true

module Gotx
  module Commands
    extend Discordrb::Commands::CommandContainer
    extend Discordrb::EventContainer

    CHANNELS = {
      dev: ENV['DEV_CHANNEL_ID'],
      rank: ENV['RANK_CHANNEL_ID']
    }.freeze

    application_command(:previous) do |event|
      game = ::Games::FuzzyFind.(event.options['game'])
      next event.respond(content: I18n.t('nominations.missing', search: event.options['game'])) unless game

      nomination = game.nominations.select(&:winner).first || game.nominations.first
      theme_date = nomination.theme.creation_date
      message = case nomination.type
                when 'RetroBits'
                  I18n.t('nominations.retro', game: game.preferred_name, date: I18n.l(theme_date, format: :long))
                else
                  status = nomination.winner? ? 'won' : 'lost'
                  date = I18n.l(theme_date, format: :month_year)
                  I18n.t("nominations.#{status}", game: game.preferred_name, type: nomination.type, date:)
                end
      event.respond(content: message)
    end

    application_command(:games) do |event|
      response = "**The current GotX games are:**\n"
      Game.current_games.each do |category, games|
        response += "**#{category}**:\n"
        games.each_with_index do |game, index|
          response += "#{index + 1}. #{game.preferred_name}\n"
        end
      end

      event.respond(content: response)
    end

    application_command(:standing) do |event|
      user = ::Users::FindOrCreate.(event.user)
      rank = User.scores.pluck(:earned_points).find_index(user.earned_points) + 1
      event.respond(ephemeral: true, content: <<~RESPONSE)
        #{event.user.mention} currently has #{user.current_points} total points, and is #{rank.ordinalize} on the GotX Leaderboard with #{user.earned_points} lifetime earned points and #{user.premium_points} lifetime premium points.
      RESPONSE
    end

    application_command(:leaderboard) do |event|
      msg = "**GotX Leaderboard**\n```"
      User.top10.each_with_index { |user, index| msg += "\n#{index + 1}. #{user.name} - #{user.earned_points}" }
      msg += "\n```"
      event.respond(content: msg)
    end

    application_command(:complete) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(member)
      next event.respond(content: I18n.t('nominations.none'), ephemeral: true) if Nomination.current_winners.none?

      event.respond(content: 'Select the game to complete', ephemeral: true) do |_, view|
        view.row do |r|
          r.select_menu(custom_id: 'game_complete', placeholder: 'Pick a game to mark completed', max_values: 1) do |s|
            (Nomination.current_winners - user.current_completions).each do |nomination|
              value = { nomination_id: nomination.id, member_id: event.options['member'] }.to_json
              s.option(label: nomination.game.preferred_name, value:)
            end
          end
        end
      end
    end

    application_command(:nominate) do |event|
      member = event.bot.user(event.user)
      user = ::Users::FindOrCreate.(member)
      begin
        validation = ::Games::ValidateNomination.(event.options.merge!('user_id' => user.id))
        if validation
          response_message = validation
        else
          game_atts = ::Scrapers::Screenscraper.(event.options)
          game = Game.create!(**game_atts)
          response_message = "#{member.mention} nominated #{game.preferred_name}"
        end
      rescue StandardError => e
        event.bot.channel(CHANNELS[:dev]).send_message(<<~ERROR)
          "Error creating GotM nomination from #{member.name}\n#{e}\n#{event.options}"
        ERROR
        response_message = 'An error occurred submitting your nomination.'
      ensure
        next event.respond(content: response_message, ephemeral: true) unless game

        event.respond(content: response_message)
        event.channel.send_embed do |embed|
          description = ":video_game: #{game.preferred_name}\n"
          description += ":calendar_spiral: #{game.year}\n" if game.year
          description += ":office: #{game.developer}\n" if game.developer
          description += ":joystick: #{game.system}\n" if game.system
          description += game_atts[:nominations_attributes][0][:description].truncate(200, separator: ' ')
          embed.description = description
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: game_atts[:img_url])
        end
      end
    end

    application_command(:membership) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(member)
      event.respond(content: 'Update premium membership status:') do |_, view|
        view.row do |r|
          r.button(label: 'Membership status', style: :secondary, custom_id: "#{user.id}_premium_member_status")
          r.button(label: 'Remove membership', style: :danger, custom_id: "#{user.id}_update_premium_member_remove")
          r.button(label: 'Add membership', style: :success, custom_id: "#{user.id}_update_premium_member_add")
        end
      end
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
        event.bot.channel(CHANNELS[:rank]).send_message("#{member.mention} is no longer a premeium subscriber.")

        next event.update_message(content: "#{user.display_name} is no longer a premium member.")
      end

      event.update_message(content: 'Update membership level:') do |_, view|
        view.row do |row|
          row.button(label: 'Supporter', style: :danger, custom_id: "#{user.id}_add_premium_membership_supporter")
          row.button(label: 'Champion', style: :success, custom_id: "#{user.id}_add_premium_membership_champion")
          row.button(label: 'Legend', style: :primary, custom_id: "#{user.id}_add_premium_membership_legend")
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

    select_menu(custom_id: 'game_complete') do |event|
      data = JSON.parse(event.values[0])
      member = event.bot.user(data['member_id'])
      user = ::Users::FindOrCreate.(member)
      nomination = Nomination.find(data['nomination_id'])
      if user.completions.find_by(nomination_id: nomination.id)
        next event.respond(content: "#{user.name} has already completed #{nomination.game.preferred_name}")
      end

      ::Nominations::Complete.(user, nomination)
      event.respond(content: "#{member.mention} #{I18n.t("nominations.completed.#{nomination.nomination_type}",
                                                         game: nomination.game.preferred_name,
                                                         points: user.current_points)}")
      event.delete_message(event.message)
    end
  end
end
