# frozen_string_literal: true

require 'csv'
puts '~~~ Starting DB Seed ~~~'

CSV.foreach('db/seeds/users.csv', headers: true) do |row|
  user = row.to_hash
  next if User.exists?(old_discord_name: user['discord_name_original'])
  next if user['discord_name_original'].blank?

  User.create(
    id: user['id'],
    name: user['discord_name'] || user['display_name'] || user['discord_name_original'].split(/#\d{4}/)[0],
    old_discord_name: user['discord_name_original'],
    discord_id: user['discord_id']&.to_i,
    premium_subscriber: user['premium']
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

ActiveRecord::Base.connection.reset_pk_sequence!('themes')

CSV.foreach('db/seeds/nominations.csv', headers: true) do |row|
  retronoms = JSON.parse(File.read('db/seeds/retronoms.txt'))

  nom = row.to_hash
  next if Nomination.exists?(id: nom['id'])

  type = case nom['nomination_type']
         when '0'
           'gotm'
         when '1'
           'retro'
           when '2'
           'rpg'
         else
           'goty'
         end

  if type == 'retro'
    retro_bit = retronoms.find { |rn| rn['game_id'].to_i == nom['game_id'].to_i }
    month, day, year = *retro_bit['date'].split('/')
    date = Date.parse("#{year}-#{month}-#{day}")
    theme = Theme.create(
      creation_date: date,
      title: "Retro Bits #{date}",
      description: "Retro Bits Theme - #{date.cweek.ordinalize} week of #{date.year}",
      nomination_type: 'retro'
    )
  end

  Nomination.create(
    id: nom['id'],
    game_id: nom['game_id'],
    user_id: nom['user_id'],
    theme_id: theme&.id || nom['theme_id'],
    description: nom['description']&.gsub('"', ''),
    nomination_type: type,
    winner: nom['is_winner'] == '1'
  )
end

ActiveRecord::Base.connection.reset_pk_sequence!('nominations')

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

Theme.all.each do |theme|
  type = theme.nominations.first&.nomination_type
  theme.update(nomination_type: type)
end

ActiveRecord::Base.connection.reset_pk_sequence!('games')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('completions')
