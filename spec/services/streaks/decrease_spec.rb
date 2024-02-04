# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streaks::Decrease do
  let(:streak) { create(:streak, :active) }

  subject { described_class.(streak) }

  describe 'call' do
    context 'with an existing streak' do
      let(:previously_incremented) { streak.last_incremented }

      it 'decreases the streak count and last incremented' do
        expect { subject }.to change { streak.reload.streak_count }
          .from(2).to(1)
          .and change { streak.reload.last_incremented }
          .from(previously_incremented).to(previously_incremented - 1.month)
      end
    end

    context 'with a newly created streak' do
      let(:streak) { create(:streak, :active, streak_count: 1) }

      it 'destroys the streak' do
        subject
        expect { streak.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
