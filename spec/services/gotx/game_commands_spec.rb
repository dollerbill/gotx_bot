# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gotx::GameCommands do
  describe '.search_results' do
    subject { described_class.search_results('grandia') }

    before { allow(Scrapers::ScreenscraperSearch).to receive(:call).with('name' => 'grandia').and_return(results) }

    context 'when games are found' do
      let(:results) do
        [
          { screenscraper_id: '19289', title: 'Grandia', system: 'Playstation', year: '1997' },
          { screenscraper_id: '13513', title: 'Grandia (Saturn)', system: nil, year: nil }
        ]
      end

      it 'lists each game with its ID and link' do
        expect(subject).to eq(<<~RESPONSE)
          **ScreenScraper results for grandia:**
          Grandia (Playstation, 1997) - ID **19289** <https://screenscraper.fr/gameinfos.php?gameid=19289>
          Grandia (Saturn) - ID **13513** <https://screenscraper.fr/gameinfos.php?gameid=13513>
        RESPONSE
      end
    end

    context 'when no games are found' do
      let(:results) { [] }

      it 'returns the not found message' do
        expect(subject).to eq('No ScreenScraper games found for grandia.')
      end
    end
  end
end
