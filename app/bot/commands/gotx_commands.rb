# frozen_string_literal: true

module GotxCommands
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  SERVER = { server_id: ENV['DISCORD_SERVER_ID'] }.freeze

  def self.register_application_commands(bot)
    bot.register_application_command(:gotx_game, 'Search for previous GotX games', **SERVER) do |cmd|
      cmd.string(:game_name, 'Name of game to search.', required: true)
    end
    bot.register_application_command(:gotx_points, 'Check you total number of GotX points', **SERVER)

    bot.register_application_command(:gotx_leaderboard, 'See the top 10 GotX point earners', **SERVER)

    bot.register_application_command(:gotx_rank, 'See your individual GotX ranking', **SERVER)
  end

  application_command(:gotx_game) do |event|
    search = event.options['game_name']
    results = {}
    %i[usa world eu jp other].each { |region| results[region] = Game.fuzzy_search("title_#{region}": search).first }

    game = results.values.compact.first
    unless game
      next event.respond(content: "#{search} has not been a GotX game. Nominate it if you want to see it win!")
    end

    nomination = game.nominations.select(&:winner).first || game.nominations.first
    message = case nomination.type
              when 'GotM'
                nomination.winner? ? winning_message(game, nomination) : losing_message(game, nomination)
              when 'RetroBits'
                "#{game_name(game)} was a Retrobit game during the week of #{nomination.theme.creation_date.strftime('%D')}."
              when 'RPGotQ'
                nomination.winner? ? winning_message(game, nomination) : losing_message(game, nomination)
              end
    event.respond(content: message)
  end

  application_command(:gotx_points) do |event|
    user = User.find_by(discord_id: event.user.id) || User.find_by(name: event.user.name)

    next event.respond(content: "#{event.user.name} has not been added to GotX, ping @rapid99 for help!") unless user

    event.respond(content: "#{event.user.name} has #{user.current_points} GotX points")
  end

  application_command(:gotx_leaderboard) do |event|
    msg = "**GotX Leaderboard**\n```"
    User.top10.each_with_index { |n, index| msg += "\n#{index + 1}. #{n}" }
    msg += "\n```"
    event.respond(content: msg)
  end

  application_command(:gotx_rank) do |event|
    user = User.find_by(discord_id: event.user.id) || User.find_by(name: event.user.name)
    next event.respond(content: "#{event.user.name} doesn't have any GotX points yet.") unless user

    rank = User.scores.pluck(:earned_points).find_index(user.earned_points) + 1
    event.respond(content: "#{user.name} is #{rank.ordinalize} on the GotX Leaderboard")
  end

  def self.game_name(game)
    game.title_usa || game.title_world || game.title_eu || game.title_jp || game.title_other
  end

  def self.winning_message(game, nomination)
    "#{game_name(game)} won #{nomination.type} in #{nomination.theme.creation_date.strftime('%B %Y')}."
  end

  def self.losing_message(game, nomination)
    "#{game_name(game)} was nominated for #{nomination.type} in #{nomination.theme.creation_date.strftime('%B %Y')}, but didn't win."
  end
end
