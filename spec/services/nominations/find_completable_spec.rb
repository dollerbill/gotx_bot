# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nominations::FindCompletable do
  let(:user) { create(:user) }
  let(:type) { 'gotm' }
  let!(:played_gotm) { create(:nomination, :winner) }
  let!(:unplayed_gotm) { create(:nomination, :winner) }
  let(:last_year) { Date.current.last_year.year }
  let(:goty_theme) { create(:theme, title: "GotY #{last_year}", nomination_type: 'goty') }
  let(:gotwoty_theme) { create(:theme, title: "GotWotY #{last_year}", nomination_type: 'gotwoty') }
  let!(:played_goty) { create(:nomination, :goty, theme: goty_theme) }
  let!(:unplayed_goty) { create(:nomination, :goty, theme: goty_theme) }
  let!(:gotwoty) { create(:nomination, :retro, theme: gotwoty_theme) }
  let!(:rpg) { create(:nomination, :rpg, :winner) }
  let!(:retro) { create(:nomination, :retro, :winner) }

  subject(:completable) { described_class.call(user, type) }

  describe 'call' do
    context 'when nomination type is gotm' do
      context 'with an existing gotm completion' do
        let!(:completion) { create(:completion, user:, nomination: played_gotm) }

        it 'returns the uncompleted games' do
          expect(completable).to eq([unplayed_gotm])
        end
      end

      context 'with no completions' do
        it 'returns all nominations' do
          expect(completable).to match_array([unplayed_gotm, played_gotm])
        end
      end
    end

    context 'when nomination type is goty' do
      let(:type) { 'goty' }

      context 'with an existing goty completion' do
        let!(:completion) { create(:completion, user:, nomination: played_goty) }

        it 'returns the gotwoty' do
          expect(completable).to eq([gotwoty])
        end
      end

      context 'with no goty completions' do
        it 'returns all goty and gotwoty games' do
          expect(completable).to match_array([gotwoty, unplayed_goty, played_goty])
        end
      end
    end

    context 'when nomination type is rpg' do
      let(:type) { 'rpg' }

      context 'with an existing completion' do
        let!(:completion) { create(:completion, user:, nomination: rpg) }

        it 'returns an empty array' do
          expect(completable).to eq([])
        end
      end

      context 'with no completions' do
        it 'returns the rpg nomination' do
          expect(completable).to eq([rpg])
        end
      end
    end

    context 'when nomination type is retro' do
      let(:type) { 'retro' }

      context 'with an existing completion' do
        let!(:completion) { create(:completion, user:, nomination: retro) }

        it 'returns an empty array' do
          expect(completable).to eq([])
        end
      end

      context 'with no completions' do
        it 'returns the retro nomination' do
          expect(completable).to eq([retro])
        end
      end
    end
  end
end
