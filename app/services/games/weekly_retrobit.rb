# frozen_string_literal: true

module Games
  class WeeklyRetrobit < CreateRecurring
    GOTW_GAMES_CHANNEL = ENV['GOTW_GAMES_CHANNEL'].freeze

    def call
      create_game
      post_announcement
      post_game
      game
    end

    private

    def theme
      Theme.create!(nomination_type:)
    end

    def nomination_type
      'retro'
    end

    def winner
      true
    end

    def message
      <<~MESSAGE
        <@&#{GOTX_ROLE_ID}> Saturday nights are for Retro Bits! Come on over to <##{channel}> and chat about this week's 2ish (or less!) hour game, **#{game.preferred_name}** and earn some cool swag doin' it!

        If this is your first week hearing about it,

        Retro Bits is like a mini Game of the Month (GotM). Every week, for one full week, from Saturday Night-Saturday Night, we feature one game that is 2 or fewer hours long according to howlongtobeat.com. Similar to GotM, users are encouraged to play and talk about that game during its weeklong duration in <##{channel}>.  Retro Bits was designed to give users a little something extra to play, in case GotM isn't jiving with them, if they just don't have time to commit to games longer than 2 hours, want a little something extra to play, and to feature some shorter games that generally don't have a shot in GotM such as (but not limited to) shmups, fighting games, beat 'em ups, short platformers, and so on. Oh, and of course to earn points for cool prizes, just like GotM!

        Have fun!

      MESSAGE
    end

    def channel
      ENV['GOTX_DISCUSSION_CHANNEL']
    end

    def description
      description = ":video_game: #{game.preferred_name}\n"
      description += ":calendar_spiral: #{game.year}\n" if game.year
      description += ":office: #{game.developer}\n" if game.developer
      description += ":joystick: #{game.system}\n" if game.system
      description += ":crossed_swords: #{game.genre}\n" if game.genre
      description += ":timer: #{game.time_to_beat}\n" if game.time_to_beat
      if atts.dig(:nominations_attributes, 0, :description)
        description += atts[:nominations_attributes][0][:description].truncate(200, separator: ' ')
      end
      description
    end

    def post_game
      bot.channel(GOTW_GAMES_CHANNEL).send_embed do |embed|
        embed.description = description
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: @game.img_url)
      end
    end
  end
end
