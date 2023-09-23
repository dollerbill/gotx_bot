# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::AddMonthlyPremiumPoints do
  let!(:legend) { create(:user, :legend) }
  let!(:champion) { create(:user, :champion) }
  let!(:supporter) { create(:user, :supporter) }

  subject { described_class.call }

  describe 'call' do
    before { allow_any_instance_of(described_class).to receive(:notify).and_return('Notified!') }

    it 'updates current and redeemed points' do
      expect { subject }
        .to change { legend.reload.premium_points }.from(0).to(3)
        .and change { champion.reload.premium_points }.from(0).to(2)
        .and change { supporter.reload.premium_points }.from(0).to(1)
    end

    it 'notifies' do
      expect(subject).to eq('Notified!')
    end
  end
end
