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
    allow(mock_bot).to receive(:token).and_return('Bot fake-token')
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
      allow(mock_server).to receive(:roles).and_return([])
      allow(Discordrb::API::Server).to receive(:resolve_members).and_return([].to_json)

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

    let(:supporter_role) { instance_double('Discordrb::Role', name: 'SUPPORTER', id: 9001) }
    let(:champion_role) { instance_double('Discordrb::Role', name: 'CHAMPION', id: 9002) }

    let(:guild_members_json) do
      [
        { 'user' => { 'id' => '555555555', 'username' => existing_supporter.name }, 'roles' => ['9001'] },
        { 'user' => { 'id' => '666666666', 'username' => user_to_upgrade.name }, 'roles' => ['9001'] }
      ].to_json
    end

    before do
      allow(User).to receive(:premium).and_return([])
      allow(mock_server).to receive(:roles).and_return([supporter_role, champion_role])
      allow(Discordrb::API::Server).to receive(:resolve_members)
        .with('Bot fake-token', '123456789', 1000, nil)
        .and_return(guild_members_json)
    end

    it 'does not update users who already have the correct membership level' do
      expect { subject }.not_to change { existing_supporter.reload.premium_subscriber }
    end

    it 'upgrades users who gain a premium role' do
      expect(Users::UpdatePremiumStatus).to receive(:call).with(user_to_upgrade, 'supporter')

      subject
    end

    it 'skips members without a premium role' do
      no_role_json = [
        { 'user' => { 'id' => '777777777', 'username' => 'nobody' }, 'roles' => ['1234'] }
      ].to_json
      allow(Discordrb::API::Server).to receive(:resolve_members).and_return(no_role_json)

      expect(Users::UpdatePremiumStatus).not_to receive(:call)
      subject
    end

    it 'maps roles to correct membership levels' do
      service_instance = described_class.new

      expect(service_instance.send(:membership_mapping, instance_double('Discordrb::Role', name: 'SUPPORTER'))).to eq('supporter')
      expect(service_instance.send(:membership_mapping, instance_double('Discordrb::Role', name: 'CHAMPION'))).to eq('champion')
      expect(service_instance.send(:membership_mapping, instance_double('Discordrb::Role', name: 'LEGEND'))).to eq('legend')
      expect(service_instance.send(:membership_mapping, instance_double('Discordrb::Role', name: 'RH Supporter'))).to eq('supporter')
    end

    it 'sends notification about new subscribers' do
      expect(mock_bot).to receive(:send_message).with('987654321', /Users:.*have become premium subscribers/)
      subject
    end

    it 'paginates when the first page is full' do
      page1 = Array.new(1000) do |i|
        { 'user' => { 'id' => (800_000 + i).to_s, 'username' => "user#{i}" }, 'roles' => [] }
      end
      page2 = [
        { 'user' => { 'id' => '900000', 'username' => 'lastuser' }, 'roles' => [] }
      ]

      allow(Discordrb::API::Server).to receive(:resolve_members)
        .with('Bot fake-token', '123456789', 1000, nil)
        .and_return(page1.to_json)
      allow(Discordrb::API::Server).to receive(:resolve_members)
        .with('Bot fake-token', '123456789', 1000, page1.last['user']['id'])
        .and_return(page2.to_json)

      subject

      expect(Discordrb::API::Server).to have_received(:resolve_members).twice
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
        allow(Discordrb::API::Server).to receive(:resolve_members).and_return([].to_json)
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

      let(:mock_roles) do
        [
          instance_double('Discordrb::Role', name: 'SUPPORTER', id: 7001),
          instance_double('Discordrb::Role', name: 'RH Champion', id: 7002),
          instance_double('Discordrb::Role', name: 'LEGEND', id: 7003)
        ]
      end

      let(:guild_members_json) do
        [
          { 'user' => { 'id' => '100001', 'username' => 'u1' }, 'roles' => ['7001'] },
          { 'user' => { 'id' => '100002', 'username' => 'u2' }, 'roles' => ['7002'] },
          { 'user' => { 'id' => '100003', 'username' => 'u3' }, 'roles' => ['7003'] }
        ].to_json
      end

      before do
        allow(User).to receive(:premium).and_return([])
        allow(mock_server).to receive(:roles).and_return(mock_roles)
        allow(Discordrb::API::Server).to receive(:resolve_members).and_return(guild_members_json)
      end

      it 'upgrades each user to the matching membership level' do
        expect(Users::UpdatePremiumStatus).to receive(:call).with(user1, 'supporter')
        expect(Users::UpdatePremiumStatus).to receive(:call).with(user2, 'champion')
        expect(Users::UpdatePremiumStatus).to receive(:call).with(user3, 'legend')

        subject
      end
    end
  end
end
