# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::FuzzyFind do
  describe 'call' do
    let(:search_term) { 'grandia' }
    let(:game) { build(:game) }

    subject { described_class.(search_term) }

    before { allow(Game).to receive(:fuzzy_search).and_return([game]) }

    it 'searches across all regions' do
      %i[usa world eu jp other].each do |region|
        expect(Game).to receive(:fuzzy_search).with({ "title_#{region}": search_term }).and_return([game])
      end
      subject
    end

    context 'when a game exactly matches the search term (case insensitive)' do
      let(:other_game) { build(:game, title_world: 'Grandia Parallel Trippers') }

      before { allow(Game).to receive(:fuzzy_search).and_return([other_game, game]) }

      it 'returns the exact match' do
        expect(subject).to eq(game)
      end
    end

    context 'when no game exactly matches the search term' do
      let(:close_game) { build(:game, title_usa: 'Grandia II') }

      before { allow(Game).to receive(:fuzzy_search).and_return([close_game]) }

      it 'returns the first match' do
        expect(subject).to eq(close_game)
      end
    end
  end
end
