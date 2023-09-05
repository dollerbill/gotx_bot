# frozen_string_literal: true

module Gotx
  module Commands
    extend Discordrb::Commands::CommandContainer
    extend Discordrb::EventContainer
    DEV_CHANNEL_ID = ENV['DEV_CHANNEL_ID']

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

      event.respond(content: <<~RESPONSE)
        #{event.user.mention} has #{user.current_points} GotX points and is #{rank.ordinalize} on the GotX Leaderboard
      RESPONSE
    end

    application_command(:leaderboard) do |event|
      msg = "**GotX Leaderboard**\n```"
      User.top10.each_with_index { |n, index| msg += "\n#{index + 1}. #{n}" }
      msg += "\n```"
      event.respond(content: msg)
    end

    application_command(:complete) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(member)
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
      validation = ::Games::ValidateNomination.(event.options.merge!('user_id' => user.id))
      next event.respond(content: validation, ephemeral: true) if validation

      game_atts = ::Scrapers::Screenscraper.(event.options)
      game = Game.create!(**game_atts)

      event.respond(content: "#{member.mention} nominated #{game.preferred_name}")
      event.channel.send_embed do |embed|
        description = game_atts[:nomination_atts][:description]
        embed.description = description.length > 300 ? "#{description[..300]}..." : description
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: game_atts[:img_url])
      end

    rescue ActiveRecord::RecordInvalid => e
      event.bot.channel(DEV_CHANNEL_ID).send_message(<<~ERROR)
        "Error creating GotM nomination from #{member.name}\n#{e.message}\n#{event.options}"
      ERROR
      event.respond(content: 'An error occurred submitting your nomination.')
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
