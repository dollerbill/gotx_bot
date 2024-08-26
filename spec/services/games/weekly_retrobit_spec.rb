# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::WeeklyRetrobit do
  let(:atts)   { { screenscraper_id: 19626 } }
  let(:bot)    { instance_double('Gotx::Bot.initialize_bot') }
  let!(:rapid) { create(:user, id: 12) }
  let(:channel) { instance_double('Discordrb::Channel', send_message: 'Message sent', send_embed: 'Embed Sent') }

  subject(:weekly_retrobit) { described_class.new(atts) }

  before do
    stub_const('Games::WeeklyRetrobit::GOTW_GAMES_CHANNEL', 'gotw_channel')
    stub_const('Games::CreateRecurring::ANNOUNCEMENT_CHANNEL_ID', 'announcement_channel')
    stub_const('Games::CreateRecurring::GOTX_ROLE_ID', 'gotx_role')
    allow(subject).to receive(:bot).and_return(bot)
    allow(bot).to receive(:channel).and_return(channel)
    allow_any_instance_of(Scrapers::Screenscraper).to receive(:call).and_return(attributes_for(:game, :screenscraper_attributes))
  end

  describe 'call' do
    context 'successful nomination' do
      it 'creates a game' do
        expect { weekly_retrobit.call }.to change { Game.count }.by(1)
        expect(Game.first.title_usa).to eq('Lunar : Silver Star Story Complete')
        expect(Game.first.nominations.first.nomination_type).to eq('retro')
      end

      it 'announces to discord' do
        weekly_retrobit.call
        expect(channel).to have_received(:send_message).with(match('Saturday nights are for Retro Bits!'))
        expect(channel).to have_received(:send_embed).exactly(2).times
      end

      it 'adds a default description' do
        weekly_retrobit.call
        expect(Game.first.nominations.first.description).to_not be_nil
      end
    end
  end
end
