# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::FindOrCreate do
  let(:member) { double('member', id: 15, name: 'User') }

  subject { described_class.(member) }

  describe 'call' do
    context 'with no existing user' do
      it 'creates a new user' do
        expect(subject)
          .to have_attributes({
                                discord_id: 15,
                                name: 'User',
                                current_points: 0,
                                redeemed_points: 0,
                                earned_points: 0
                              })
      end
    end

    context 'with an existing user' do
      let!(:existing_user) { User.create(discord_id: 15, name: 'User') }

      it 'returns the users existing streak' do
        expect(subject).to eq(existing_user)
      end
    end
  end
end
