# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streaks::Increase do
  let(:user) { User.new(name: 'name') }
  let(:streak) { Streak.new(user:, start_date: 1.months.ago.beginning_of_month, streak_count: 1) }

  subject { described_class.(streak) }

  describe 'call' do
    it 'updates streak attributes' do
      expect { subject }.to change { streak.streak_count }.from(1).to(2)
      expect(streak.last_incremented).to eq(Date.current.beginning_of_month)
    end
  end
end
