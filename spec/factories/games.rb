# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id               :bigint           not null, primary key
#  title_usa        :string
#  title_eu         :string
#  title_jp         :string
#  title_world      :string
#  title_other      :string
#  year             :string
#  system           :string
#  developer        :string
#  genre            :string
#  img_url          :string
#  time_to_beat     :integer
#  screenscraper_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
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
  end
end
