# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Completions::Remove do
  let(:completion) { create(:completion) }

  subject { described_class.(completion) }

  describe 'call' do
    before { completion.user.update(earned_points: 1) }

    it 'deletes the completion' do
      expect { subject }.to change { Completion.count }
        .by(-1)
        .and change { completion.user.reload.earned_points }
        .by(-1)
        .and change { completion.user.reload.current_points }.by(-1)
    end

    context 'with an active streak' do
      let(:streak) { create(:streak, :active, user: completion.user) }

      it 'decreases the streak' do
        expect { subject }.to change { streak.reload.streak_count }.by(-1)
      end
    end

    context 'with no streak' do
      it 'does not decrease the streak' do
        expect(Streaks::Decrease).to_not receive(:call)
        subject
      end
    end

    context 'from a non gotm completion' do
      before { completion.nomination.update(nomination_type: :goty) }

      it 'does not decrease the streak' do
        expect(Streaks::Decrease).to_not receive(:call)
        subject
      end
    end
  end
end
