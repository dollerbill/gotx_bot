# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streak, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe 'scopes' do
    let!(:new)    { create(:streak) }
    let!(:active) { create(:streak, :active) }
    let!(:broken) { create(:streak, :broken) }

    context 'active' do
      it 'returns active streaks' do
        expect(Streak.active.count).to eq(1)
      end
    end

    context 'broken' do
      it 'returns active streaks' do
        expect(Streak.active.count).to eq(1)
      end
    end

    context 'newly_started' do
      it 'returns active streaks' do
        expect(Streak.active.count).to eq(1)
      end
    end
  end
end
