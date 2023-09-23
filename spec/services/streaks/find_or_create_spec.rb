# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streaks::FindOrCreate do
  let(:user_id) { User.create(name: 'name').id }

  subject { described_class.(user_id) }

  describe 'call' do
    context 'with no existing streak' do
      it 'creates a new streak' do
        expect(subject).to have_attributes({ user_id:, end_date: nil, last_incremented: nil, streak_count: nil })
      end
    end

    context 'with an existing streak' do
      let(:start) { 1.months.ago.beginning_of_month }
      let!(:existing_streak) { Streak.create(user_id:, start_date: start, streak_count: 2) }

      it 'returns the users existing streak' do
        expect(subject).to eq(existing_streak)
      end
    end
  end
end
