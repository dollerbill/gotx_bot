# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSerializer, type: :serializer do
  let(:game) { create(:game) }

  subject { described_class.new(game).as_json }

  it 'serializes the expected attributes' do
    expect(subject).to eq(
      {
        developer: 'Game Arts',
        genre: 'RPG',
        genres: 'RPG',
        img_url: 'https://screenscraper.fr/image.php?gameid=19289&media=ss&maxwidth=640&maxheight=480&region=wor',
        name: 'Grandia',
        screenscraper_id: 19289,
        system: 'PS1',
        systems: 'PS1',
        time_to_beat: 42,
        year: '1997',
        description: 'Nomination for a game!'
      }
    )
  end
end
