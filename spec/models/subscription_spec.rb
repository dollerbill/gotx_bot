# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  context 'callbacks' do
    it 'sets the default start date' do
      subscription = create(:subscription)
      expect(subscription.start_date).to eq(Date.current.beginning_of_month)
    end
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe 'scopes' do
    let!(:active) { create(:subscription, :active) }
    let!(:cancelled) { create(:subscription, :cancelled) }
    let!(:newly_subscribed) { create(:subscription, :newly_subscribed) }

    context 'active' do
      it 'returns active subscriptions' do
        expect(described_class.active.count).to eq(1)
      end
    end

    context 'cancelled' do
      it 'returns cancelled subscriptions' do
        expect(described_class.cancelled.count).to eq(1)
      end
    end

    context 'newly_subscribed' do
      it 'returns newly started subscriptions' do
        expect(described_class.newly_subscribed.count).to eq(1)
      end
    end
  end
end
