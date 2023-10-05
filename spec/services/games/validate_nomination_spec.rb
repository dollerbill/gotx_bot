# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'invalid nomination' do |error|
  it { is_expected.to include error }
end

RSpec.describe Games::ValidateNomination do
  let!(:game) { create(:game) }
  let(:open) { true }
  let(:user) { build(:user) }
  let(:atts) { { 'user_id' => user.id, 'screenscraper_id' => game&.screenscraper_id } }

  subject { described_class.call(atts) }

  before { allow(Nomination).to receive(:open?).and_return(open) }

  describe 'call' do
    context 'successful nomination' do
      it { is_expected.to be_nil }
    end

    context 'invalid nomination' do
      context 'nominations closed' do
        let(:open) { false }
        it_behaves_like 'invalid nomination', 'Nominations are closed'
      end

      context 'user already nominated' do
        before { allow_any_instance_of(described_class).to receive(:user_already_nominated?).and_return(true) }

        it_behaves_like 'invalid nomination', 'You may only nominate one game'
      end

      context 'game already nominated' do
        let!(:nomination) { create(:nomination, game:) }

        before { allow(Nomination).to receive(:current_nominations).and_return(Nomination.where(id: nomination.id)) }

        it_behaves_like 'invalid nomination', 'has already been nominated'
      end

      context 'game previously won' do
        let(:theme) { create(:theme, :previous) }
        let!(:nomination) { create(:nomination, :winner, theme:, game:) }

        it_behaves_like 'invalid nomination', 'has already won'
      end
    end
  end
end