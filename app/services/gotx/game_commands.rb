# frozen_string_literal: true

module Gotx
  module GameCommands
    include CommandBase

    application_command(:previous) do |event|
      event.respond(content: previous_game(event.options['game']))
    end

    def self.previous_game(game_name)
      game = ::Games::FuzzyFind.(game_name)
      return I18n.t('nominations.missing', search: game_name) unless game.nominations.any?

      nomination = game.nominations.find(&:winner) || game.nominations.first
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
          r.button(label: 'GotM', style: :primary, custom_id: "#{user.id}_game_complete_gotm", emoji: 1042504406064701500)
          r.button(label: 'Retrobit', style: :secondary, custom_id: "#{user.id}_game_complete_retro", emoji: 1042504406064701500)
          r.button(label: 'RPGotQ', style: :success, custom_id: "#{user.id}_game_complete_rpg", emoji: 1042504406064701500)
          r.button(label: 'GotY', style: :danger, custom_id: "#{user.id}_game_complete_goty", emoji: 1042504406064701500)
        end
      end
    end

    application_command(:nominate) do |event|
      ActiveRecord::Base.connection_pool.with_connection do
        user = ::Users::FindOrCreate.(event.user)
        game = Game.find_by(screenscraper_id: event.options['screenscraper_id'])
        validation = ::Games::ValidateNomination.(event.options.merge!('user' => user, 'game' => game))
        next event.respond(content: validation) if validation

        event.respond(content: 'Nomination is being created, please watch for the result.', ephemeral: true)

        if game
          Nomination.create!(user:, game:, theme: Theme.gotm.find_by('creation_date >=?', Date.current))
          game_atts = { img_url: game.img_url, nominations_attributes: [{ description: event.options['description'] }] }
        else
          game_atts = ::Scrapers::Screenscraper.(event.options)
          game = Game.create!(**game_atts)
        end
        event.channel.send_message("#{event.user.mention} nominated #{game.preferred_name}!")
        event.channel.send_embed do |embed|
          embed.description = build_description(game, game_atts)
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: game_atts[:img_url])
        end
      end
    rescue StandardError => e
      next if e.instance_of?(ActiveRecord::ConnectionNotEstablished)

      event.bot.channel(CHANNELS[:dev]).send_message(<<~ERROR)
        Error creating GotM nomination from #{event.user.name}\n#{e}\n#{event.options}
      ERROR
      event.user.dm(<<~DM)
        An error occurred submitting your nomination (ScreenScraper ID #{event.options['screenscraper_id']}), please try again.
      DM
    end

    def self.build_description(game, game_atts)
      description = ":video_game: #{game.preferred_name}\n"
      description += ":calendar_spiral: #{game.year}\n" if game.year
      description += ":office: #{game.developer}\n" if game.developer
      description += ":joystick: #{game.systems.join(', ')}\n" if game.systems.any?
      description += ":crossed_swords: #{game.genres.join(', ')}\n" if game.genres.any?
      description += ":timer: #{game.time_to_beat}\n" if game.time_to_beat
      description += "https://screenscraper.fr/gameinfos.php?gameid=#{game.screenscraper_id}\n"
      description + (game_atts.dig(:nominations_attributes, 0, :description)&.truncate(200, separator: ' ') || '')
    end

    button(custom_id: /\d_game_complete/) do |event|
      user = User.find(event.interaction.button.custom_id.split('_')[0])
      type = event.interaction.button.custom_id.split('game_complete_')[1]
      available = Nominations::FindCompletable.(user, type)

      next event.update_message(content: "There are no remaining #{type} games to complete for #{user.name}.") if available.empty?

      if %w[retro rpg].include?(type)
        member = event.bot.user(user.discord_id)
        nomination = available.first
        ::Nominations::Complete.(user, nomination)
        event.respond(content: "#{member.mention} #{completion_message(nomination, user)}")
        event.delete_message(event.message)
      else
        event.update_message(content: 'Select the game to complete') do |_, view|
          view.row do |r|
            r.select_menu(custom_id: 'game_complete', placeholder: 'Games', max_values: 1) do |s|
              available.each do |nom|
                value = { nomination_id: nom.id, member_id: user.discord_id }.to_json
                s.option(label: nom.game.preferred_name, value:, emoji: 1042504406064701500)
              end
            end
          end
        end
      end
    end

    def self.completion_message(nomination, user)
      type = %w[retro gotwoty].include?(nomination.nomination_type) ? 'retro' : 'base'
      I18n.t("nominations.completed.#{type}", game: nomination.game.preferred_name, points: user.earned_points)
    end

    select_menu(custom_id: 'game_complete') do |event|
      data = JSON.parse(event.values[0])
      member = event.bot.user(data['member_id'])
      user = ::Users::FindOrCreate.(member)
      nom = Nomination.find(data['nomination_id'])
      if user.completions.find_by(nomination_id: nom.id)
        next event.respond(content: I18n.t('users.already_completed', user: user.name, game: nom.game.preferred_name))
      end

      ::Nominations::Complete.(user, nom)
      event.respond(content: "#{member.mention} #{completion_message(nom, user)}")
      event.delete_message(event.message)
    end
  end
end
