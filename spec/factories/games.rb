# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    title_world { 'Grandia' }
    year { '1997' }
    system { 'PS1' }
    developer { 'Game Arts' }
    genre { 'RPG' }
    img_url { 'https://screenscraper.fr/image.php?gameid=19289&media=ss&maxwidth=640&maxheight=480&region=wor' }
    time_to_beat { 42 }
    screenscraper_id { 19_289 }

    # rubocop:disable Layout/LineLength
    trait :screenscraper_attributes do
      screenscraper_id { '19626' }
      title_usa { 'Lunar : Silver Star Story Complete' }
      title_jp { 'Lunar : Silver Star Story' }
      title_other { 'Lunar - Silver Star Story Complete' }
      year { '1998' }
      system { 'Playstation' }
      developer { 'Game Arts' }
      genre { 'Role playing games' }
      img_url { 'https://screenscraper.fr/image.php?gameid=19626&region=wor&media=ss&maxwidth=640&maxheight=480' }
      nominations_attributes do
        [
          {
            user_id: create(:user).id,
            description: 'Alex, a young boy from a small humble town, enters a life of adventure and intrigue after being chosen as the heir-apparent to the title of &quot;Dragonmaster&quot;, guardian of the forces of the planet. With the help of his expanding band of companions, Alex must pass the trials set by ancient dragons to claim his place in history, and stop a powerful sorcerer and former hero, Ghaleon, from controlling the world.'
          }
        ]
      end
    end
    # rubocop:enable Layout/LineLength
  end
end
