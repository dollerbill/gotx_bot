# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::FuzzyFind do
  describe 'call' do
    let(:search_term) { 'grandia' }
    let!(:game) { create(:game) }

    subject { described_class.(search_term) }

    it 'searches across all regions' do
      %i[usa world eu jp other].each do |region|
        expect(Game).to receive(:fuzzy_search).with({ "title_#{region}": search_term }).and_call_original
      end
      subject
    end

    context 'when a game exactly matches the search term (case insensitive)' do
      let!(:other_game) { create(:game, title_world: 'Grandia Parallel Trippers') }

      it 'returns the exact match' do
        expect(subject).to eq(game)
      end
    end

    context 'when no game exactly matches the search term' do
      let!(:game) { nil }

      context 'when a game includes the search term' do
        let!(:close_game) { create(:game, title_usa: 'Grandia II') }

        it { is_expected.to eq(close_game) }
      end

      context 'when a game is fuzzily similar to the search term' do
        let!(:close_game) { create(:game, title_usa: 'Grand Chase') }

        it { is_expected.to eq(close_game) }
      end
    end
  end
end
