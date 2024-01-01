# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::Update do
  let(:subscription) { build(:subscription, :active, last_subscribed: 1.month.ago.beginning_of_month) }

  subject { described_class.(subscription) }

  describe 'call' do
    it 'updates subscription attributes' do
      expect { subject }.to change { subscription.subscribed_months }.from(5).to(6)
      expect(subscription.last_subscribed).to eq(Date.current.beginning_of_month)
    end
  end
end
