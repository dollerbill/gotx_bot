# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nomination, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :game }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :theme }
    it { is_expected.to have_many :completions }
  end

  describe 'scopes' do
    let(:gotm_theme)    { build(:theme) }
    let(:goty_theme)    { build(:theme, :goty, title: "goty #{Date.current.last_year.year}") }
    let(:gotwoty_theme) { build(:theme, :gotwoty, title: "gotwoty #{Date.current.last_year.year}") }
    let(:rpg_theme)     { build(:theme, :rpg) }
    let(:retro_theme)   { build(:theme, :retro) }

    let!(:gotm)    { create(:nomination, :winner, theme: gotm_theme) }
    let!(:goty)    { create(:nomination, :winner, :goty, theme: goty_theme) }
    let!(:gotwoty) { create(:nomination, :winner, :goty, theme: gotwoty_theme) }
    let!(:rpg)     { create(:nomination, :winner, :rpg, theme: rpg_theme) }
    let!(:retro)   { create(:nomination, :winner, :retro, theme: retro_theme) }

    context 'winners' do
      it 'returns all winners' do
        expect(Nomination.winners.count).to eq(5)
      end
    end

    context 'current_retro_winners' do
      it 'returns the most recent retro winner' do
        expect(Nomination.current_retro_winners).to eq([retro])
      end
    end

    context 'current_gotm_winners' do
      it 'returns the current gotm winner' do
        expect(Nomination.current_gotm_winners).to eq([gotm])
      end
    end

    context 'current_goty_winners' do
      it 'returns the current goty winner' do
        expect(Nomination.current_goty_winners).to eq([goty, gotwoty])
      end
    end

    context 'current_rpg_winners' do
      it 'returns the current rpg winner' do
        expect(Nomination.current_rpg_winners).to eq([rpg])
      end
    end

    context 'current_nominations' do
      before do
        allow(Theme).to receive(:current_gotm_theme).and_return([gotm_theme])
        allow(Theme).to receive(:current_rpg).and_return([rpg_theme])
      end

      it 'returns the current nominations' do
        expect(Nomination.current_nominations).to match_array([gotm, rpg])
      end
    end

    context 'previous_winners' do
      before do
        allow(Theme).to receive(:most_recent).with('gotm').and_return([gotm])
        allow(Theme).to receive(:most_recent).with('goty').and_return([goty])
        allow(Theme).to receive(:most_recent).with('gotwoty').and_return([gotwoty])
        allow(Theme).to receive(:most_recent).with('rpg').and_return([rpg])
        allow(Theme).to receive(:most_recent).with('retro').and_return([retro])
      end

      it 'returns winners for previous themes' do
        expect(Nomination.previous_winners('gotm').count).to eq(1)
        expect(Nomination.previous_winners('goty').count).to eq(1)
        expect(Nomination.previous_winners('rpg').count).to eq(1)
        expect(Nomination.previous_winners('retro').count).to eq(1)
      end
    end
  end
end
