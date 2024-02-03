# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'invalid nomination' do |error|
  it { is_expected.to include error }
end

RSpec.describe Games::ValidateNomination do
  let!(:game) { create(:game) }
  let(:open) { true }
  let(:user) { build(:user) }
  let(:atts) { { 'user' => user, 'screenscraper_id' => game&.screenscraper_id, 'game' => nil } }

  subject { described_class.call(atts) }

  before { allow(Nomination).to receive(:open?).and_return(open) }

  describe 'call' do
    context 'successful nomination' do
      it { is_expected.to be_nil }

      context 'previous rpg winner from over a year ago' do
        let(:theme) { create(:theme, :previous, :rpg, creation_date: 2.years.ago) }
        let!(:nomination) { create(:nomination, :winner, :rpg, theme:, game:, user:) }

        it { is_expected.to be_nil }
      end

      context 'when passing in an existing game' do
        let(:atts) { super().merge('game' => game) }

        it { is_expected.to be_nil }
      end
    end

    context 'invalid nomination' do
      context 'when passing in an existing game' do
        let(:atts) { super().merge('game' => game) }
        let!(:existing_nomination) { create(:nomination, game:) }

        before { allow(Theme).to receive(:current_gotm_theme).and_return([existing_nomination.theme]) }

        it_behaves_like 'invalid nomination', 'has already been nominated'
      end

      context 'nominations closed' do
        let(:open) { false }

        it_behaves_like 'invalid nomination', 'Nominations are closed'
      end

      context 'user already nominated' do
        let!(:nomination) { create(:nomination, user:) }

        before { allow(Theme).to receive(:current_gotm_theme).and_return([nomination.theme]) }

        it_behaves_like 'invalid nomination', 'You may only nominate one game'
      end

      context 'game already nominated' do
        let!(:nomination) { create(:nomination, game:) }

        before { allow(Theme).to receive(:current_gotm_theme).and_return([nomination.theme]) }

        it_behaves_like 'invalid nomination', 'has already been nominated'
      end

      context 'game previously won' do
        let!(:nomination) { create(:nomination, :winner, game:, theme: create(:theme, :previous)) }

        it_behaves_like 'invalid nomination', 'has already won'
      end

      context 'previous weekly winners from within the past year' do
        let(:theme) { create(:theme, :previous, :retro) }
        let!(:nomination) { create(:nomination, :winner, :retro, game:, theme:, user:) }

        it_behaves_like 'invalid nomination', 'was a RetroBit game in the past year.'
      end
    end
  end
end
