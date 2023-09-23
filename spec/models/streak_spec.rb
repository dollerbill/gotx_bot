# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streak, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :user }
  end

  xdescribe 'scopes' do
    before do
    end

    context 'active' do
      it 'returns active streaks' do
        expect(described_class.active.count).to eq(3)
      end
    end

    context 'broken' do
      it 'returns active streaks' do
        expect(described_class.active.count).to eq(1)
      end
    end

    context 'newly_started' do
      it 'returns active streaks' do
        expect(described_class.active.count).to eq(2)
      end
    end
  end
end
