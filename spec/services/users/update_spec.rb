# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Update do
  let(:user) { create(:user, :current_points) }
  let(:atts) { { current_points: 99, redeemed_points: 1 } }

  subject { described_class.(user, atts) }

  describe 'call' do
    before do
      allow_any_instance_of(described_class).to receive_message_chain(:bot, :send_message).and_return('Notified!')
      expect(user).to have_attributes(current_points: 150, redeemed_points: 0)
    end

    it 'notifies' do
      expect(subject).to eq('Notified!')
    end

    it 'updates point attributes' do
      expect { subject }.to change { user.current_points }
        .from(150).to(99)
        .and change { user.redeemed_points }.from(0).to(1)
    end

    context 'with same values' do
      let(:atts) { { current_points: 150, redeemed_points: 0 } }
      it 'does not update' do
        expect(subject).to eq(nil)
        expect(user).to have_attributes(current_points: 150, redeemed_points: 0)
      end
    end
  end
end
