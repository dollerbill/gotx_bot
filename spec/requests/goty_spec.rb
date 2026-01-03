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
    let!(:theme) { create(:theme, :goty, creation_date: Date.new(2024, 1, 1), title: 'GotY 2024') }

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

    context 'when GotWotY winner exists' do
      let!(:gotwoty_theme) { create(:theme, :gotwoty, creation_date: Date.new(2024, 1, 1), title: 'GotWotY 2024') }
      let!(:gotwoty_game) { create(:game, title_world: 'Jumping Flash!') }
      let!(:gotwoty_user) { create(:user, name: 'RetroGamer') }
      let!(:gotwoty_nomination) do
        gotwoty_theme.nominations.create!(
          description: '2024 GotWotY Winner',
          nomination_type: 'gotwoty',
          winner: true,
          game: gotwoty_game,
          user: gotwoty_user
        )
      end

      it 'displays the GotWotY winner' do
        subject
        expect(response.body).to include('Jumping Flash!')
        expect(response.body).to include('RetroGamer')
      end

      it 'does not display the GotWotY form' do
        subject
        expect(response.body).not_to include('Add GotWotY Winner')
        expect(response.body).to include('GotWotY Winner')
      end
    end

    context 'when GotWotY winner does not exist' do
      it 'displays the GotWotY form' do
        subject
        expect(response.body).to include('Add GotWotY Winner')
        expect(response.body).to include('Search for a Game of the Week')
      end

      it 'does not display the green winner card' do
        subject
        expect(response.body).not_to include('bg-green-50')
      end
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

  describe 'GET /goty/:id/eligible_gotw_games' do
    let!(:theme) { create(:theme, :goty, creation_date: Date.new(2025, 1, 1), title: 'GotY 2025') }

    subject { get eligible_gotw_games_goty_path(theme) }

    it_behaves_like 'unauthorized'

    context 'with eligible GotW games from the same year' do
      let!(:eligible_theme) { create(:theme, creation_date: Date.new(2025, 6, 1), title: 'Retro Week June 2025') }
      let!(:winning_game) { create(:game, title_world: 'Jumping Flash!') }
      let!(:nominator) { create(:user, name: 'OriginalNominator') }
      let!(:winning_nomination) do
        create(:nomination, :winner,
               game: winning_game,
               user: nominator,
               theme: eligible_theme,
               nomination_type: 'retro')
      end

      let!(:ineligible_theme) { create(:theme, creation_date: Date.new(2024, 6, 1), title: 'Retro Week June 2024') }
      let!(:old_game) { create(:game, title_world: 'Pac-Man') }
      let!(:old_nomination) do
        create(:nomination, :winner,
               game: old_game,
               user: nominator,
               theme: ineligible_theme,
               nomination_type: 'retro')
      end

      let!(:gotm_theme) { create(:theme, creation_date: Date.new(2025, 3, 1), title: 'March 2025') }
      let!(:gotm_game) { create(:game, title_world: 'Chrono Trigger') }
      let!(:gotm_nomination) do
        create(:nomination, :winner,
               game: gotm_game,
               user: nominator,
               theme: gotm_theme,
               nomination_type: 'gotm')
      end

      it 'returns JSON with eligible GotW games from the same year' do
        subject
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.map { |g| g['name'] }).to include('Jumping Flash!')
      end

      it 'excludes games from other years' do
        subject
        json = JSON.parse(response.body)
        expect(json.map { |g| g['name'] }).not_to include('Pac-Man')
      end

      it 'excludes GotM games' do
        subject
        json = JSON.parse(response.body)
        expect(json.map { |g| g['name'] }).not_to include('Chrono Trigger')
      end

      it 'includes nominator_id for attribution' do
        subject
        json = JSON.parse(response.body)
        jumping_flash = json.find { |g| g['name'] == 'Jumping Flash!' }
        expect(jumping_flash['nominator_id']).to eq(nominator.id)
      end
    end
  end

  describe 'POST /goty/:id/add_gotwoty_nomination' do
    let!(:theme) { create(:theme, :goty, creation_date: Date.new(2025, 1, 1), title: 'GotY 2025') }
    let!(:eligible_theme) { create(:theme, creation_date: Date.new(2025, 6, 1), title: 'Retro Week June 2025') }
    let!(:winning_game) { create(:game, title_world: 'Jumping Flash!') }
    let!(:nominator) { create(:user, name: 'OriginalNominator') }
    let!(:winning_nomination) do
      create(:nomination, :winner,
             game: winning_game,
             user: nominator,
             theme: eligible_theme,
             nomination_type: 'retro')
    end

    subject { post add_gotwoty_nomination_goty_path(theme), params: { game_id: winning_game.id } }

    it_behaves_like 'unauthorized'

    context 'when no GotWotY theme exists' do
      it 'creates a new GotWotY theme' do
        expect { subject }.to change { Theme.gotwoty.count }.by(1)
      end

      it 'creates the theme with correct attributes' do
        subject
        gotwoty_theme = Theme.gotwoty.last
        expect(gotwoty_theme.title).to eq('GotWotY 2025')
        expect(gotwoty_theme.description).to eq('GotWotY for 2025')
        expect(gotwoty_theme.creation_date).to eq(Date.new(2025, 1, 1))
      end

      it 'creates a nomination in the GotWotY theme' do
        subject
        gotwoty_theme = Theme.gotwoty.last
        expect(gotwoty_theme.nominations.count).to eq(1)
      end

      it 'sets the correct nomination attributes' do
        subject
        gotwoty_theme = Theme.gotwoty.last
        nomination = gotwoty_theme.nominations.first
        expect(nomination.description).to eq('2025 GotWotY Winner')
        expect(nomination.game).to eq(winning_game)
        expect(nomination.user).to eq(nominator)
        expect(nomination.winner).to be true
        expect(nomination.nomination_type).to eq('gotwoty')
      end

      it 'redirects back to GotY show page' do
        subject
        expect(response).to redirect_to(goty_path(theme))
      end
    end

    context 'when GotWotY theme already exists' do
      let!(:existing_gotwoty_theme) do
        create(:theme, :gotwoty, creation_date: Date.new(2025, 1, 1), title: 'GotWotY 2025')
      end

      it 'does not create a new theme' do
        expect { subject }.not_to change { Theme.gotwoty.count }
      end

      it 'adds nomination to existing theme' do
        expect { subject }.to change { existing_gotwoty_theme.nominations.count }.by(1)
      end
    end

    context 'when GotWotY winner already exists' do
      let!(:existing_gotwoty_theme) do
        create(:theme, :gotwoty, creation_date: Date.new(2025, 1, 1), title: 'GotWotY 2025')
      end
      let!(:existing_game) { create(:game, title_world: 'Existing Winner') }
      let!(:existing_nomination) do
        create(:nomination, :winner,
               game: existing_game,
               user: nominator,
               theme: existing_gotwoty_theme,
               nomination_type: 'gotwoty')
      end

      it 'does not create a new nomination' do
        expect { subject }.not_to change { Nomination.gotwoty.count }
      end

      it 'shows error and redirects' do
        subject
        expect(response).to redirect_to(goty_path(theme))
        expect(flash[:alert]).to include('already been selected')
      end
    end

    context 'when game has no winning GotW nomination' do
      let!(:non_gotw_game) { create(:game, title_world: 'Some Game') }

      subject { post add_gotwoty_nomination_goty_path(theme), params: { game_id: non_gotw_game.id } }

      it 'shows error and redirects' do
        subject
        expect(response).to redirect_to(goty_path(theme))
        expect(flash[:alert]).to include('Could not find')
      end
    end

    context 'when no game is selected' do
      subject { post add_gotwoty_nomination_goty_path(theme), params: { game_id: nil } }

      it 'shows error' do
        subject
        expect(response).to redirect_to(goty_path(theme))
        expect(flash[:alert]).to include('Please select a game')
      end
    end
  end
end
