# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gotx::CommandBase do
  def discord_user(id:, name: 'someone')
    instance_double('Discordrb::Member', id:, name:)
  end

  describe '.admin?' do
    it 'is true for a User with admin set' do
      create(:user, discord_id: 111111111, admin: true)

      expect(described_class.admin?(discord_user(id: 111111111))).to be(true)
    end

    it 'is false for an existing non-admin User' do
      create(:user, discord_id: 222222222)

      expect(described_class.admin?(discord_user(id: 222222222))).to be(false)
    end

    it 'is false for a Discord user with no User row, and creates none' do
      expect { described_class.admin?(discord_user(id: 333333333)) }
        .not_to change(User, :count)

      expect(described_class.admin?(discord_user(id: 333333333))).to be(false)
    end

    it 'is false for a name collision with an admin under a different discord_id' do
      create(:user, name: 'BilboBaggins', discord_id: 444444444, admin: true)
      impostor = discord_user(id: 555555555, name: 'BilboBaggins')

      expect(described_class.admin?(impostor)).to be(false)
    end
  end

  describe 'rejection message' do
    it 'renders' do
      expect(I18n.t('errors.not_authorized')).to eq("You don't have permission to use this command.")
    end
  end
end
