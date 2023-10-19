# frozen_string_literal: true

module Gotx
  module GameCommands
    include CommandBase

    application_command(:previous) do |event|
      event.respond(content: previous_game(event.options['game']))
    end

    def self.previous_game(game_name)
      game = ::Games::FuzzyFind.(game_name)
      return I18n.t('nominations.missing', search: game_name) unless game

      nomination = game.nominations.select(&:winner).first || game.nominations.first
      theme_date = nomination.theme.creation_date
      case nomination.type
      when 'RetroBits'
        I18n.t('nominations.retro', game: game.preferred_name, date: I18n.l(theme_date, format: :long))
      else
        status = nomination.winner? ? 'won' : 'lost'
        date = I18n.l(theme_date, format: :month_year)
        I18n.t("nominations.#{status}", game: game.preferred_name, type: nomination.type, date:)
      end
    end

    application_command(:games) do |event|
      event.respond(content: games_list)
    end

    def self.games_list
      response = "**The current GotX games are:**\n"
      Game.current_games.each do |category, games|
        response += "**#{category}**:\n"
        games.each_with_index do |game, index|
          response += "#{index + 1}. #{game.preferred_name}\n"
        end
      end
      response
    end

    application_command(:goty_games) do |event|
      event.respond(content: goty_games_list)
    end

    def self.goty_games_list
      response = "**The current GotY games are:**\n"
      Game.current_goty_games.each do |category, games|
        response += "**#{category}**:\n"
        games.each_with_index do |game, index|
          response += "#{index + 1}. #{game.preferred_name}\n"
        end
      end
      response
    end

    application_command(:complete) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(member)

      event.respond(content: 'Select Game type to complete:', ephemeral: true) do |_, view|
        view.row do |r|
          r.button(label: 'GotM', style: :primary, custom_id: "#{user.id}_game_complete_gotm")
          r.button(label: 'Retrobit', style: :secondary, custom_id: "#{user.id}_game_complete_retro")
          r.button(label: 'RPGotQ', style: :success, custom_id: "#{user.id}_game_complete_rpg")
          r.button(label: 'GotY', style: :danger, custom_id: "#{user.id}_game_complete_goty")
        end
      end
    end

    application_command(:nominate) do |event|
      ActiveRecord::Base.connection_pool.with_connection do
        user = ::Users::FindOrCreate.(event.user)
        event.options.merge!('user_id' => user.id)
        # validation = ::Games::ValidateNomination.(event.options.merge!('user_id' => user.id))
        # next event.respond(content: validation) if validation

        event.respond(content: 'Nomination is being created, please watch for the result.', ephemeral: true)

        game_atts = ::Scrapers::Screenscraper.(event.options)
        binding.pry
        game = Game.create!(**game_atts)
        event.channel.send_message("#{event.user.mention} nominated #{game.preferred_name}!")
        event.channel.send_embed do |embed|
          embed.description = build_description(game, game_atts)
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: game_atts[:img_url])
        end
      end
    rescue StandardError => e
      event.bot.channel(CHANNELS[:dev]).send_message(<<~ERROR)
        Error creating GotM nomination from #{event.user.name}\n#{e}\n#{event.options}
      ERROR
      event.user.dm(<<~DM)
        An error occurred submitting your nomination (ScreenScraper ID #{event.options['screenscraper_id']}), please try again.
      DM
    end

    application_command(:gotx_vote) do |event|
      member = event.bot.user(event.options['member'])
      user = ::Users::FindOrCreate.(event.user)

      event.respond(content: 'Cast your GotM vote:', ephemeral: true)# do |_, view|
      event.send_message(content: 'Select the game to complete', ephemeral: true) do |_, view|
        view.row do |r|
          r.select_menu(custom_id: 'gotx_voting', placeholder: 'Pick a game to mark completed', max_values: 1) do |s|
            value = { nomination_id: Nomination.winners.first.id, member_id: member.id }.to_json
            s.option(label: Nomination.winners.first.game.preferred_name, value: value)
          end
        end
      end
    end

    def self.build_description(game, game_atts)
      description = ":video_game: #{game.preferred_name}\n"
      description += ":calendar_spiral: #{game.year}\n" if game.year
      description += ":office: #{game.developer}\n" if game.developer
      description += ":joystick: #{game.system}\n" if game.system
      description += ":crossed_swords: #{game.genre}\n" if game.genre
      description += ":timer: #{game.time_to_beat}\n" if game.time_to_beat
      description += "https://screenscraper.fr/gameinfos.php?gameid=#{game.screenscraper_id}\n"
      description + (game_atts.dig(:nominations_attributes, 0, :description)&.truncate(200, separator: ' ') || '')
    end

    button(custom_id: /\d_game_complete/) do |event|
      user = User.find(event.interaction.button.custom_id.split('_')[0])
      type = event.interaction.button.custom_id.split('game_complete_')[1]
      available = Nominations::FindCompletable.(user, type)

      if available.empty?
        next event.update_message(content: "There are no remaining #{type} games to complete for #{user.name}.")
      end

      event.update_message(content: 'Select the game to complete') do |_, view|
        view.row do |r|
          r.select_menu(custom_id: 'game_complete', placeholder: 'Pick a game to mark completed', max_values: 1) do |s|
            available.each do |nomination|
              value = { nomination_id: nomination.id, member_id: user.discord_id }.to_json
              s.option(label: nomination.game.preferred_name, value:)
            end
          end
        end
      end
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
      translation_key = nomination.nomination_type == 'retro' ? 'retro' : 'base'
      event.respond(content: "#{member.mention} #{I18n.t("nominations.completed.#{translation_key}",
                                                         game: nomination.game.preferred_name,
                                                         points: user.earned_points)}")
      event.delete_message(event.message)
    end

    select_menu(custom_id: 'gotx_voting') do |event|
      data = JSON.parse(event.values[0])

      nomination = Nomination.find(data['nomination_id'])
      member = event.bot.user(data['member_id'])
      user = ::Users::FindOrCreate.(member)
      Vote.create!(nomination:, user:)
      event.respond(content: 'Thanks for voting!', ephemeral: true)
      event.delete_message(event.message)
    end
  end
end
