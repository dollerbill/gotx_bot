# frozen_string_literal: true

require 'csv'
puts '~~~ Starting DB Seed ~~~'

CSV.foreach('db/seeds/users.csv', headers: true) do |row|
  user = row.to_hash
  next if User.exists?(old_discord_name: user['discord_name_original'])

  User.create(
    id: user['id'],
    name: user['discord_name'] || user['display_name'] || user['discord_name_original'].split(/#\d{4}/)[0],
    old_discord_name: user['discord_name_original']
  )
end

CSV.foreach('db/seeds/themes.csv', headers: true) do |row|
  theme = row.to_hash
  next if Theme.exists?(id: theme['id'])

  Theme.create(
    id: theme['id'],
    creation_date: theme['creation_date'],
    title: theme['title'],
    description: theme['description']&.gsub('"', '')
  )
end

CSV.foreach('db/seeds/games.csv', headers: true) do |row|
  game = row.to_hash
  next if Game.exists?(id: game['id'])

  Game.create(
    title_usa: game['title_usa'],
    title_eu: game['title_eu'],
    title_jp: game['title_jap'],
    title_world: game['title_world'],
    title_other: game['title_other'],
    year: game['year'],
    system: game['system'],
    developer: game['developer'],
    genre: game['genre'],
    img_url: game['img'],
    time_to_beat: game['time_to_beat'],
    screenscraper_id: game['screenscraper_id']
  )
end

# CSV.foreach('db/seeds/rpg_games.csv', headers: true) do |row|
#   game = row.to_hash
#   next if Game.exists?(screenscraper_id: game['screenscraper_id'])
#
#   record = Game.create(
#     title_usa: game['title_usa'],
#     title_eu: game['title_eu'],
#     title_jp: game['title_jap'],
#     title_world: game['title_world'],
#     title_other: game['title_other'],
#     year: game['year'],
#     system: game['system'],
#     developer: game['developer'],
#     genre: game['genre'],
#     img_url: game['img'],
#     time_to_beat: game['time_to_beat'],
#     screenscraper_id: game['screenscraper_id']
#   )
#
#   nominations = CSV.read('db/seeds/rpg_nominations.csv', headers: true)
#   nom = nominations.find { |nomination| nomination['game_id'] == game['id'] }.to_hash
#   creation_date = nom['creation_date'].match(/-(\d{2})-/)[1]
#   theme = case creation_date
#           when '01'
#             Theme.find_by(title: 'RPGotQ 1')
#           when '04'
#             Theme.find_by(title: 'RPGotQ 2')
#           when '07'
#             Theme.find_by(title: 'RPGotQ 3')
#           end
#   winner = %w[1 2 9].include?(nom['id'])
#
#   Nomination.create(game: record, theme:, winner:, nomination_type: 'rpg',
#                     user: User.find_by(old_discord_name: 'Rapid99#9203'))
# end

CSV.foreach('db/seeds/nominations.csv', headers: true) do |row|
  nom = row.to_hash
  next if Nomination.exists?(id: nom['id'])

  # winner = CSV.read('db/seeds/gotm_winners.csv', headers: true).any? do |game|
  #   game.to_hash['nomination_id'] == nom['id']
  # end
  type = case nom['nomination_type']
         when '0'
           'gotm'
         when '1'
           'retro'
         else
           'rpg'
         end

  Nomination.create(
    id: nom['id'],
    game_id: nom['game_id'],
    user_id: nom['user_id'],
    theme_id: nom['theme_id'],
    description: nom['description']&.gsub('"', ''),
    nomination_type: type,
    winner: nom['is_winner'] == '1'
  )
end
ActiveRecord::Base.connection.reset_pk_sequence!('themes')
ActiveRecord::Base.connection.reset_pk_sequence!('nominations')

# CSV.foreach('db/seeds/retrobits.csv', headers: true) do |row|
#   game = row.to_hash
#   next if game['title_usa'] && Game.exists?(title_usa: game['title_usa'])
#
#   Game.create(
#     title_usa: game['title_usa'],
#     title_eu: game['title_eu'],
#     title_jp: game['title_jap'],
#     title_world: game['title_world'],
#     title_other: game['title_other'],
#     year: game['year'],
#     system: game['system'],
#     developer: game['developer'],
#     genre: game['genre'],
#     img_url: game['img'],
#     time_to_beat: game['time_to_beat'],
#     screenscraper_id: game['screenscraper_id']
#   ).tap do |record|
#     date = game['creation_date']
#     Nomination.create(
#       nomination_type: 'retro',
#       game: record,
#       user: User.find_by(old_discord_name: 'Rapid99#9203'),
#       theme: Theme.create(
#         title: "Retrobits #{date.to_date.strftime('%D')}",
#         created: date,
#         description: "Retrobits game, week of #{date}"
#       )
#     )
#   end
# end

CSV.foreach('db/seeds/GotM Leaderboard.csv', headers: true) do |row|
  data = row.to_hash
  user = User.find_by(name: data['Username']) || User.find_by(old_discord_name: data['Username'])

  next Rails.logger.warn((data['Username']).to_s) unless user
  next if user.earned_points.positive?

  user.update(
    current_points: data['Total Current Points'].to_i,
    redeemed_points: data['Points Spent'].to_i,
    earned_points: data['Points Earned'].to_i,
    premium_points: data['Patreon Points'].to_i
  )
end

CSV.foreach('db/seeds/completions.csv', headers: true) do |row|
  completion = row.to_hash
  next unless (user = User.find(completion['user_id'])) && (nomination = Nomination.find(completion['nomination_id']))

  Completion.create(user:, nomination:, completed_at: nomination.theme.creation_date)
end

ActiveRecord::Base.connection.reset_pk_sequence!('games')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('completions')
