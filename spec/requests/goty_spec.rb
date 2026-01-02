# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Goty', type: :request do
  include_context 'Auth Helper'

  describe 'POST /goty' do
    subject { post goty_index_path }

    it_behaves_like 'unauthorized'

    context 'when no GotY theme exists for the year' do
      it 'creates a new GotY theme' do
        expect { subject }.to change { Theme.goty.count }.by(1)
      end

      it 'creates a default GotY Winner nomination without a game' do
        subject
        theme = Theme.goty.last
        expect(theme.nominations.count).to eq(1)
        expect(theme.nominations.first.description).to eq("#{theme.creation_date.year} GotY Winner")
        expect(theme.nominations.first.game_id).to be_nil
      end

      it 'redirects to the GotY show page' do
        subject
        expect(response).to redirect_to(goty_path(Theme.goty.last))
      end
    end

    context 'when GotY theme already exists for the next year to be created' do
      it 'creates themes for consecutive years when called multiple times' do
        expect { subject }.to change { Theme.goty.count }.by(1)
        first_year = Theme.goty.order(creation_date: :desc).first.creation_date.year

        expect { post goty_index_path }.to change { Theme.goty.count }.by(1)
        second_year = Theme.goty.order(creation_date: :desc).first.creation_date.year

        expect(second_year).to eq(first_year + 1)
      end
    end
  end

  describe 'GET /goty/:id' do
    let!(:theme) { create(:theme, :goty, title: 'GotY 2024') }

    subject { get goty_path(theme) }

    it_behaves_like 'unauthorized'

    it 'displays the theme title' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('GotY 2024')
    end

    it 'displays existing nominations' do
      game = create(:game, title_world: 'Chrono Trigger')
      user = create(:user, name: 'TestUser')
      theme.nominations.create!(
        description: '2024 GotY Winner',
        nomination_type: 'goty',
        winner: true,
        game:,
        user:
      )

      subject
      expect(response.body).to include('Chrono Trigger')
      expect(response.body).to include('TestUser')
    end
  end

  describe 'GET /goty/:id/eligible_games' do
    let!(:theme) { create(:theme, :goty, creation_date: Date.new(2025, 1, 1), title: 'GotY 2025') }

    subject { get eligible_games_goty_path(theme) }

    it_behaves_like 'unauthorized'

    context 'with eligible games from the same year' do
      let!(:eligible_theme) { create(:theme, creation_date: Date.new(2025, 6, 1), title: 'June 2025') }
      let!(:winning_game) { create(:game, title_world: 'Chrono Trigger') }
      let!(:nominator) { create(:user, name: 'OriginalNominator') }
      let!(:winning_nomination) do
        create(:nomination, :winner,
               game: winning_game,
               user: nominator,
               theme: eligible_theme,
               nomination_type: 'gotm')
      end

      let!(:ineligible_theme) { create(:theme, creation_date: Date.new(2024, 6, 1), title: 'June 2024') }
      let!(:old_game) { create(:game, title_world: 'Final Fantasy VI') }
      let!(:old_nomination) do
        create(:nomination, :winner,
               game: old_game,
               user: nominator,
               theme: ineligible_theme,
               nomination_type: 'gotm')
      end

      it 'returns JSON with eligible games from the same year' do
        subject
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.map { |g| g['name'] }).to include('Chrono Trigger')
      end

      it 'excludes games from other years' do
        subject
        json = JSON.parse(response.body)
        expect(json.map { |g| g['name'] }).not_to include('Final Fantasy VI')
      end

      it 'includes nominator_id for attribution' do
        subject
        json = JSON.parse(response.body)
        chrono = json.find { |g| g['name'] == 'Chrono Trigger' }
        expect(chrono['nominator_id']).to eq(nominator.id)
      end
    end
  end

  describe 'POST /goty/:id/add_nomination' do
    let!(:theme) { create(:theme, :goty, creation_date: Date.new(2025, 1, 1), title: 'GotY 2025') }
    let!(:eligible_theme) { create(:theme, creation_date: Date.new(2025, 6, 1), title: 'June 2025') }
    let!(:winning_game) { create(:game, title_world: 'Chrono Trigger') }
    let!(:nominator) { create(:user, name: 'OriginalNominator') }
    let!(:winning_nomination) do
      create(:nomination, :winner,
             game: winning_game,
             user: nominator,
             theme: eligible_theme,
             nomination_type: 'gotm')
    end

    subject { post add_nomination_goty_path(theme), params: { description: '2025 GotY Best RPG', game_id: winning_game.id } }

    it_behaves_like 'unauthorized'

    it 'creates a new nomination' do
      expect { subject }.to change { theme.nominations.count }.by(1)
    end

    it 'sets the correct attributes' do
      subject
      nomination = theme.nominations.last
      expect(nomination.description).to eq('2025 GotY Best RPG')
      expect(nomination.game).to eq(winning_game)
      expect(nomination.user).to eq(nominator)
      expect(nomination.winner).to be true
      expect(nomination.nomination_type).to eq('goty')
    end

    it 'redirects back to show page' do
      subject
      expect(response).to redirect_to(goty_path(theme))
    end

    context 'when game has no winning nomination' do
      let!(:non_winner_game) { create(:game, title_world: 'Some Game') }

      subject { post add_nomination_goty_path(theme), params: { description: 'Test', game_id: non_winner_game.id } }

      it 'shows error and redirects' do
        subject
        expect(response).to redirect_to(goty_path(theme))
        expect(flash[:alert]).to include('Could not find')
      end
    end

    context 'when description is blank' do
      subject { post add_nomination_goty_path(theme), params: { description: '', game_id: winning_game.id } }

      it 'shows error' do
        subject
        expect(response).to redirect_to(goty_path(theme))
        expect(flash[:alert]).to include('Category name is required')
      end
    end
  end
end
