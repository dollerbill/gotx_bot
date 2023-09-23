# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RedeemPoints do
  let(:user) { build(:user, :current_points) }
  let(:points) { 15 }

  subject { described_class.(user, points) }

  describe 'call' do
    before { expect(user).to have_attributes(current_points: 150, redeemed_points: 0) }

    it 'updates current and redeemed points' do
      expect { subject }.to change { user.current_points }
        .from(150).to(135)
        .and change { user.redeemed_points }.from(0).to(15)
    end
  end
end
