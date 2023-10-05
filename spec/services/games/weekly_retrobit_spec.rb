# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::WeeklyRetrobit do
  let(:atts) { attributes_for(:game, :screenscraper_attributes) }
  let(:bot) { instance_double('Gotx::Bot.initialize_bot') }
  let(:channel) do
    instance_double('Discordrb::Channel', send_message: 'Message sent', send_embed: 'Embed Sent')
  end

  subject(:weekly_retrobit) { described_class.new(atts) }

  before do
    stub_const('Games::WeeklyRetrobit::GOTW_GAMES_CHANNEL', 'gotw_channel')
    stub_const('Games::CreateRecurring::ANNOUNCEMENT_CHANNEL_ID', 'announcement_channel')
    stub_const('Games::CreateRecurring::GOTX_ROLE_ID', 'gotx_role')
    allow(subject).to receive(:bot).and_return(bot)
    allow(bot).to receive(:channel).and_return(channel)
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
    end
  end
end
