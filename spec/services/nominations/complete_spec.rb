# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'earned points' do
  it 'adds points' do
    expect(subject.points).to eq(earned_points)
  end
end

RSpec.shared_examples 'successful completion' do
  before { complete.call }
  it 'creates a completion' do
    expect(user.completions).to exist
  end

  it 'updates points' do
    expect(user.earned_points).to eq(earned_points)
  end
end

RSpec.describe Nominations::Complete do
  let(:skip) { nil }
  let(:user) { nomination.user }
  let(:nomination) { create(:nomination) }
  let(:earned_points) { 1 }

  subject(:complete) { described_class.new(user, nomination, skip) }
  describe 'new' do
    context 'completion points' do
      context 'gotm' do
        it_behaves_like 'earned points'
      end

      context 'goty' do
        let(:nomination) { create(:nomination, :goty) }

        it_behaves_like 'earned points'
      end

      context 'rpg' do
        let(:nomination) { create(:nomination, :rpg) }

        it_behaves_like 'earned points'
      end

      context 'retro' do
        let(:nomination) { create(:nomination, :retro) }
        let(:earned_points) { 0.5 }
        it_behaves_like 'earned points'
      end
    end
  end

  describe 'call' do
    context 'with an existing streak' do
      let!(:streak) { create(:streak, :active, user:) }
      it_behaves_like 'successful completion'

      it 'updates the streak' do
        expect { complete.call }.to change { streak.reload.streak_count }.from(2).to(3)
      end

      context 'when providing skip' do
        let(:skip) { true }

        before { allow(Streaks::Update).to receive(:call) }

        it 'does not update the streak' do
          expect { complete.call }.not_to change { streak.reload.streak_count }
          expect(Streaks::Update).to_not have_received(:call)
        end
      end
    end

    context 'after a broken streak' do
      let!(:streak) { create(:streak, :broken, streak_count: 10, user:) }

      it 'creates a new streak' do
        expect { complete.call }.to change { user.streaks.reload.count }.from(1).to(2)
        expect(user.streaks.last.streak_count).to eq(1)
      end
    end

    context 'with no existing user streak' do
      it_behaves_like 'successful completion'

      it 'creates a new streak' do
        expect { complete.call }.to change { user.streaks.count }.from(0).to(1)
        expect(user.streaks.first.last_incremented).to eq(Date.current.beginning_of_month)
      end
    end

    context 'for non-gotm nominations' do
      let(:earned_points) { 0.5 }
      let(:nomination) { create(:nomination, :retro) }

      it_behaves_like 'successful completion'

      it 'does not create a streak' do
        expect { complete.call }.to change { user.reload.earned_points }.by(0.5)
        expect(user.streaks.count).to eq(0)
      end
    end
  end
end
