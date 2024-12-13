# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'invalid nomination' do |error|
  it { is_expected.to include error }
end

RSpec.describe Users::ValidateCompletion do
  let(:nomination) { create(:nomination, game:) }
  let(:game) { create(:game) }
  let(:user) { build(:user) }
  let(:atts) { { 'user' => user, 'screenscraper_id' => game&.screenscraper_id, 'game' => game } }

  subject { described_class.call(atts) }

  describe 'call' do
    context 'successful completion' do
      it { is_expected.to be_nil }
    end

    context 'invalid completion' do
      context 'user already recorded 3 completions' do
        let(:game) { nil }

        it { is_expected.to eq('Not a valid game.') }
      end

      context 'user already recorded 3 completions' do
        before { 3.times { create(:completion, completed_at: '2025-01-10', user:) } }

        it { is_expected.to eq('You have already recorded 3 completions for this month.') }
      end

      context 'user completing a duplicate game' do
        let!(:completion) { create(:completion, user:, nomination:) }

        it { is_expected.to eq('You have already recorded a completion for this game.') }
      end
    end
  end
end
