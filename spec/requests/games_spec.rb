# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :request do
  include_context 'Auth Helper'

  let(:game)   { create(:game) }
  let!(:games) { [game] }
  let!(:rapid)  { create(:user, id: 12) }

  describe 'GET /index' do
    subject { get games_path }

    it_behaves_like 'unauthorized'

    it 'renders games data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(game.preferred_name)
    end
  end

  describe 'GET /show' do
    subject { get game_path(game.id) }

    it_behaves_like 'unauthorized'

    it 'displays a games data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(game.preferred_name)
    end
  end

  describe 'GET /new' do
    subject { get game_path(game.id) }

    it_behaves_like 'unauthorized'

    it 'displays a games data' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /edit' do
    subject { get edit_game_path(game.id) }

    it_behaves_like 'unauthorized'

    it 'fetches the edit form for the correct record' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(game.preferred_name)
    end
  end

  describe 'POST /create_weekly_retrobit' do
    let(:atts) { { screenscraper_id: 123 } }

    before { allow_any_instance_of(Scrapers::Screenscraper).to receive(:call).and_return(attributes_for(:game, :screenscraper_attributes)) }

    subject { post create_weekly_retrobit_games_path(atts) }

    it_behaves_like 'unauthorized'

    context 'with valid atts' do
      it 'creates a RetroBit game and sends an announcement to discord' do
        expect_any_instance_of(Games::WeeklyRetrobit).to receive(:post_announcement).and_return('Notified')
        expect_any_instance_of(Games::WeeklyRetrobit).to receive(:post_game).and_return('Notified')
        expect { subject }.to change { Game.count }.by(1)
                                                   .and change { Nomination.count }.by(1)
                                                   .and change { Theme.count }.by(1)
        expect(response).to redirect_to(game_path(Game.last))
      end
    end

    context 'when the game already exists' do
      before { Game.create!(atts.merge(title_usa: 'Sonic')) }

      it 'finds the already nominated game instead of creating a duplicate' do
        expect_any_instance_of(Games::WeeklyRetrobit).to receive(:post_announcement).and_return('Notified')
        expect_any_instance_of(Games::WeeklyRetrobit).to receive(:post_game).and_return('Notified')
        expect { subject }.to change { Nomination.count }.by(1).and change { Theme.count }.by(1).and change { Game.count }.by(0)
        expect(response).to redirect_to(game_path(Game.last))
      end
    end
  end

  describe 'POST /create_monthly_rpg' do
    let(:atts) { { screenscraper_id: 999, time_to_beat: 55, theme_id: theme.id } }
    let!(:theme) { create(:theme, :rpg) }

    before { allow_any_instance_of(Scrapers::Screenscraper).to receive(:call).and_return(attributes_for(:game, :screenscraper_attributes)) }

    subject { post create_monthly_rpg_games_path(atts) }

    it_behaves_like 'unauthorized'

    context 'with valid atts' do
      it 'creates an RPGotQ game and sends an announcement to discord' do
        expect { subject }.to change { Game.count }.by(1).and change { Nomination.count }.by(1)
        expect(response).to redirect_to(game_path(Game.last))
      end
    end

    context 'when the game already exists' do
      before { create(:game, screenscraper_id: 999, title_usa: 'Wild Arms') }

      it 'finds the already nominated game instead of creating a duplicate' do
        expect { subject }.to change { Nomination.count }.by(1).and change { Game.count }.by(0).and change { Theme.count }.by(0)
        expect(response).to redirect_to(game_path(Game.last))
      end
    end
  end

  describe 'PATCH /update' do
    let(:atts) { { game: { title_usa: 'Grandia best game ever' } } }

    subject { patch game_path(game, atts) }

    it_behaves_like 'unauthorized'

    context 'with valid attributes' do
      it 'updates the record' do
        subject
        expect(game.reload.preferred_name).to eq('Grandia best game ever')
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(game_path(game))
      end
    end

    context 'with invalid attributes' do
      before { allow_any_instance_of(Game).to receive(:update).and_return(false) }

      it 'fails to update' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
