# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gotx::GameCommands do
  describe '.rpg_achievements_message' do
    let(:user) { create(:user) }
    let(:member) { double(mention: '@member') }

    it 'reports when the member has no current RPGotQ completion' do
      expect(described_class.rpg_achievements_message(user, member)).to include("hasn't completed")
    end

    it 'flags the current RPGotQ completion' do
      completion = create(:completion, user:, nomination: create(:nomination, :rpg, :winner))
      expect(described_class.rpg_achievements_message(user, member)).to include('earned 100%')
      expect(completion.reload.rpg_achievements).to be(true)
    end

    it 'reports when already flagged' do
      create(:completion, user:, nomination: create(:nomination, :rpg, :winner)).update!(rpg_achievements: true)
      expect(described_class.rpg_achievements_message(user, member)).to include('already has 100%')
    end

    it 'ignores past RPGotQ completions' do
      past = create(:theme, :rpg, creation_date: Date.current.last_quarter.beginning_of_quarter)
      create(:completion, user:, nomination: create(:nomination, :rpg, :winner, theme: past))
      expect(described_class.rpg_achievements_message(user, member)).to include("hasn't completed")
    end
  end
end
