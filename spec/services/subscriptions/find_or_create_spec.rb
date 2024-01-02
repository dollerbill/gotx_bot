# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::FindOrCreate do
  let(:user) { build(:user, :legend) }

  subject { described_class.(user) }

  describe 'call' do
    context 'with no existing subscription' do
      it 'creates a new subscription' do
        expect(subject).to have_attributes({ user:, end_date: nil, last_subscribed: nil, subscribed_months: 0 })
      end
    end

    context 'with an existing active subscription' do
      let!(:existing_subscription) { create(:subscription, :active, user:) }

      it 'returns the users existing subscription' do
        expect(subject).to eq(existing_subscription)
      end
    end

    context 'with a newly subscribed subscription' do
      let!(:existing_subscription) { create(:subscription, :newly_subscribed, user:) }

      it 'returns the users existing subscription' do
        expect(subject).to eq(existing_subscription)
      end
    end
  end
end
