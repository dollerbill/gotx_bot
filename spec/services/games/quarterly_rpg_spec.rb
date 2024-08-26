# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::QuarterlyRpg do
  let(:theme) { create(:theme, :rpg) }
  let(:atts)  { { screenscraper_id: 19626, time_to_beat: 45, theme_id: theme.id } }
  let!(:rapd) { create(:user, id: 12) }

  subject(:quarterly_rpg) { described_class.new(atts) }

  before { allow_any_instance_of(Scrapers::Screenscraper).to receive(:call).and_return(attributes_for(:game, :screenscraper_attributes)) }

  describe 'call' do
    context 'successful nomination' do
      it 'creates a game' do
        expect { quarterly_rpg.call }.to change { Game.count }.by(1)
        expect(Game.first.title_usa).to eq('Lunar : Silver Star Story Complete')
        expect(Game.first.nominations.first.nomination_type).to eq('rpg')
      end
    end
  end
end
