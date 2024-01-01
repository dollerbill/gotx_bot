# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::UpdateMonthly do
  let!(:legend) { create(:user, :legend) }
  let!(:champion) { create(:user, :champion) }
  let!(:supporter) { create(:user, :supporter) }

  subject { described_class.call }

  describe 'call' do
    it 'finds or creates subscriptions' do
      allow(Subscriptions::FindOrCreate).to receive(:call).and_call_original
      expect(Subscriptions::FindOrCreate).to receive(:call).exactly(3).times
      subject
    end

    it 'updates subscriptions' do
      expect { subject }.to change { Subscription.count }.from(0).to(3)
      expect(legend.reload.subscriptions.first.subscribed_months).to eq(1)
    end
  end
end
