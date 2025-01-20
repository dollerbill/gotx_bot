# frozen_string_literal: true

# == Schema Information
#
# Table name: streaks
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  start_date       :date             not null
#  end_date         :date
#  last_incremented :date
#  streak_count     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
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

  describe 'lifecycle' do
    context '#active?' do
      subject { build(:streak, :active).active? }

      it { is_expected.to eq(true) }
    end

    context '#new?' do
      subject { build(:streak).new? }

      it { is_expected.to eq(true) }
    end
  end
end
