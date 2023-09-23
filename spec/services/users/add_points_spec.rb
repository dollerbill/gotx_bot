# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::AddPoints do
  let(:user) { create(:user, :current_points) }
  let(:points) { 15 }

  subject { described_class.(user, points) }

  describe 'call' do
    before { expect(user).to have_attributes(current_points: 150, redeemed_points: 0) }

    it 'updates current and redeemed points' do
      expect { subject }.to change { user.current_points }
        .from(150).to(165)
        .and change { user.earned_points }.from(100).to(115)
    end
  end
end
