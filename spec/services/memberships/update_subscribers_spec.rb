# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Memberships::UpdateSubscribers do
  let(:mock_bot) { instance_double('Discordrb::Commands::CommandBot') }
  let(:mock_server) { instance_double('Discordrb::Server') }

  before do
    stub_const('Memberships::UpdateSubscribers::SERVER_ID', '123456789')
    stub_const('Memberships::UpdateSubscribers::GOTX_CHANNEL_ID', '987654321')
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOTX_CHANNEL_ID').and_return('987654321')
    allow(ENV).to receive(:[]).with('DISCORD_SERVER_ID').and_return('123456789')

    allow(Gotx::Bot).to receive(:initialize_bot).and_return(mock_bot)
    allow(mock_bot).to receive(:server).with('123456789').and_return(mock_server)
    allow(mock_bot).to receive(:send_message)
  end

  subject { described_class.call }

  describe '#remove_canceled_subscribers' do
    let!(:premium_user_with_role) { create(:user, :supporter, discord_id: 111111111) }
    let!(:premium_user_without_role) { create(:user, :legend, discord_id: 222222222) }
    let!(:premium_user_no_member) { create(:user, :champion, discord_id: 333333333) }
    let!(:non_premium_user) { create(:user, discord_id: 444444444) }

    let(:mock_member_with_role) do
      instance_double('Discordrb::Member').tap do |member|
        allow(member).to receive(:roles).and_return([
                                                      instance_double('Discordrb::Role', name: 'SUPPORTER')
                                                    ])
      end
    end

    let(:mock_member_without_role) do
      instance_double('Discordrb::Member').tap do |member|
        allow(member).to receive(:roles).and_return([
                                                      instance_double('Discordrb::Role', name: 'Regular User')
                                                    ])
      end
    end

    before do
      allow(mock_bot).to receive(:member).with('123456789', 111111111).and_return(mock_member_with_role)
      allow(mock_bot).to receive(:member).with('123456789', 222222222).and_return(mock_member_without_role)
      allow(mock_bot).to receive(:member).with('123456789', 333333333).and_return(nil)
      # Stub additional calls for update_new_subscribers method
      allow(mock_server).to receive(:roles).and_return([])

      allow(Users::UpdatePremiumStatus).to receive(:call)
    end

    it 'removes premium status from users who no longer have premium roles' do
      subject

      expect(Users::UpdatePremiumStatus).to have_received(:call).with(premium_user_without_role)
    end

    it 'skips users who still have premium roles' do
      subject

      expect(Users::UpdatePremiumStatus).not_to have_received(:call).with(premium_user_with_role)
    end

    it 'skips users with no Discord member found' do
      subject

      expect(Users::UpdatePremiumStatus).not_to have_received(:call).with(premium_user_no_member)
    end

    it 'sends notification with removed users' do
      expect(mock_bot).to receive(:send_message).with('987654321', /Users:.*are no longer premium subscribers/)

      subject
    end

    it 'does not process non-premium users' do
      subject

      expect(mock_bot).not_to have_received(:member).with('123456789', 444444444)
    end
  end

  describe '#update_new_subscribers' do
    let!(:existing_supporter) { create(:user, :supporter, discord_id: 555555555) }
    let!(:user_to_upgrade) { create(:user, discord_id: 666666666) }

    let(:mock_supporter_role) do
      instance_double('Discordrb::Role').tap do |role|
        allow(role).to receive(:name).and_return('SUPPORTER')
        allow(role).to receive(:members).and_return([
                                                      mock_existing_member,
                                                      mock_new_member
                                                    ])
      end
    end

    let(:mock_champion_role) do
      instance_double('Discordrb::Role').tap do |role|
        allow(role).to receive(:name).and_return('CHAMPION')
        allow(role).to receive(:members).and_return([])
      end
    end

    let(:mock_existing_member) do
      instance_double('Discordrb::Member').tap do |member|
        allow(member).to receive(:id).and_return('555555555')
      end
    end

    let(:mock_new_member) do
      instance_double('Discordrb::Member').tap do |member|
        allow(member).to receive(:id).and_return('666666666')
      end
    end

    before do
      # Stub remove_canceled_subscribers method calls - ensure no premium users exist for this context
      allow(User).to receive(:premium).and_return([])
      allow(mock_server).to receive(:roles).and_return([mock_supporter_role, mock_champion_role])
      allow(User).to receive(:find_by).with(discord_id: '555555555').and_return(existing_supporter)
      allow(User).to receive(:find_by).with(discord_id: '666666666').and_return(user_to_upgrade)
    end

    it 'does not update users who already have the correct membership level' do
      expect { subject }.not_to change { existing_supporter.reload.premium_subscriber }
    end

    it 'processes users who need membership updates' do
      # This test verifies the logic identifies users needing updates
      # The actual update is commented out in the service, so we just verify identification
      expect(User).to receive(:find_by).with(discord_id: '666666666')

      subject
    end

    it 'maps roles to correct membership levels' do
      service_instance = described_class.new

      supporter_role = instance_double('Discordrb::Role', name: 'SUPPORTER')
      champion_role = instance_double('Discordrb::Role', name: 'CHAMPION')
      legend_role = instance_double('Discordrb::Role', name: 'LEGEND')
      rh_supporter_role = instance_double('Discordrb::Role', name: 'RH Supporter')

      expect(service_instance.send(:membership_mapping, supporter_role)).to eq('supporter')
      expect(service_instance.send(:membership_mapping, champion_role)).to eq('champion')
      expect(service_instance.send(:membership_mapping, legend_role)).to eq('legend')
      expect(service_instance.send(:membership_mapping, rh_supporter_role)).to eq('supporter')
    end

    it 'sends notification about new subscribers' do
      expect(mock_bot).to receive(:send_message).with('987654321', /Users:.*have become premium subscribers/)
      subject
    end
  end

  describe '#call' do
    before do
      allow_any_instance_of(described_class).to receive(:remove_canceled_subscribers)
      allow_any_instance_of(described_class).to receive(:update_new_subscribers)
    end

    it 'calls both subscription update methods' do
      expect_any_instance_of(described_class).to receive(:remove_canceled_subscribers)
      expect_any_instance_of(described_class).to receive(:update_new_subscribers)

      subject
    end
  end

  describe 'edge cases' do
    context 'when Discord API is unavailable' do
      before do
        allow(mock_bot).to receive(:member).and_raise(StandardError, 'API Error')
        allow(mock_server).to receive(:roles).and_return([])
        allow(Rails.logger).to receive(:error)
      end

      it 'handles API errors gracefully' do
        create(:user, :supporter, discord_id: 999999999)

        expect { subject }.not_to raise_error
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch member 999999999: API Error/)
      end
    end

    context 'with various premium role types' do
      let!(:user1) { create(:user, discord_id: 100001) }
      let!(:user2) { create(:user, discord_id: 100002) }
      let!(:user3) { create(:user, discord_id: 100003) }

      let(:roles_data) do
        [
          { name: 'SUPPORTER', members: [{ id: '100001' }] },
          { name: 'RH Champion', members: [{ id: '100002' }] },
          { name: 'LEGEND', members: [{ id: '100003' }] }
        ]
      end

      before do
        mock_roles = roles_data.map do |role_data|
          instance_double('Discordrb::Role').tap do |role|
            allow(role).to receive(:name).and_return(role_data[:name])

            mock_members = role_data[:members].map do |member_data|
              instance_double('Discordrb::Member').tap do |member|
                allow(member).to receive(:id).and_return(member_data[:id])
              end
            end

            allow(role).to receive(:members).and_return(mock_members)
          end
        end

        allow(mock_server).to receive(:roles).and_return(mock_roles)

        # Mock User.find_by calls
        allow(User).to receive(:find_by).with(discord_id: '100001').and_return(user1)
        allow(User).to receive(:find_by).with(discord_id: '100002').and_return(user2)
        allow(User).to receive(:find_by).with(discord_id: '100003').and_return(user3)
      end

      it 'handles different premium role types correctly' do
        expect(User).to receive(:find_by).with(discord_id: '100001')
        expect(User).to receive(:find_by).with(discord_id: '100002')
        expect(User).to receive(:find_by).with(discord_id: '100003')

        subject
      end
    end
  end
end
