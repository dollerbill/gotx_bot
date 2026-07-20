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

  describe 'admin changes' do
    let(:mock_bot) { instance_double('Discordrb::Commands::CommandBot') }
    let(:messages) { [] }

    before do
      allow_any_instance_of(described_class).to receive(:bot).and_return(mock_bot)
      allow(mock_bot).to receive(:send_message) { |_channel, msg| messages << msg }
    end

    context 'granting admin' do
      let(:atts) { { admin: true } }

      it 'updates the flag and announces it' do
        expect { subject }.to change { user.reload.admin }.from(false).to(true)
        expect(messages.last).to include('Admin GRANTED')
      end
    end

    context 'revoking admin' do
      let(:user) { create(:user, admin: true) }
      let(:atts) { { admin: false } }

      it 'updates the flag and announces it' do
        expect { subject }.to change { user.reload.admin }.from(true).to(false)
        expect(messages.last).to include('Admin REVOKED')
      end
    end

    context 'when admin is unchanged' do
      let(:atts) { { current_points: 99 } }

      it 'says nothing about admin' do
        subject
        expect(messages.last).not_to include('Admin')
      end
    end
  end
end
