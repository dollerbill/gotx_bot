# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streaks::EndBroken do
  let!(:broken_streak) { create(:streak, streak_count: 2, last_incremented: 2.months.ago.beginning_of_month) }
  let!(:active_streak) { create(:streak, :active) }
  let!(:old_streak) { create(:streak, :broken) }

  subject { described_class.call }

  describe 'call' do
    it 'ends newly broken streaks' do
      expect { subject }.to change { broken_streak.reload.end_date }
        .from(nil).to(Date.current.last_month.beginning_of_month)
      expect(broken_streak.streak_count).to eq(2)
    end

    it 'ignores already broken streaks' do
      expect { subject }.not_to change { old_streak.reload.end_date }
    end

    it 'ignores active streaks' do
      expect { subject }.not_to change { active_streak.reload.end_date }
    end
  end
end
