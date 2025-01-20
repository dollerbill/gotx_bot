# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ValidateCompletion do
  let(:nomination) { create(:nomination, :winner) }
  let(:game) { create(:game, nominations: [nomination]) }
  let(:user) { build(:user) }
  let(:atts) { { 'user' => user, 'screenscraper_id' => game&.screenscraper_id, 'game' => game } }

  subject { described_class.call(atts) }

  describe 'call' do
    context 'successful completion' do
      it { is_expected.to be_nil }
    end

    context 'when a user has 3 completions between different GOTX categories' do
      before do
        %i[gotm retro goty].each do |type|
          create(:completion, completed_at: '2025-01-10', nomination: create(:nomination, type), user:)
        end
      end

      it { is_expected.to be_nil }
    end

    context 'invalid completion' do
      context 'when a user already recorded 3 gotm completions' do
        before { 3.times { create(:completion, completed_at: '2025-01-10', user:) } }

        it { is_expected.to eq(' has already recorded 3 completions for this month.') }
      end

      context 'when a user completes a duplicate game' do
        let!(:completion) { create(:completion, user:, nomination:) }

        it { is_expected.to eq(' has already recorded a completion for this game.') }
      end
    end
  end
end
