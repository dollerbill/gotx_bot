# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gotx::GameCommands do
  describe '.completion_message' do
    let(:user) { create(:user, earned_points: 3) }
    let(:nomination) { create(:nomination, :rpg, :winner) }

    it 'uses the base message by default' do
      expect(described_class.completion_message(nomination, user)).to include('awarded 1 point!')
    end

    it 'uses the 100% message when achievements are recorded' do
      expect(described_class.completion_message(nomination, user, achievements: true))
        .to include('with 100% achievements and been awarded 3 points! They have earned 3.0 total points')
    end
  end

  describe '.rpg_achievements_message' do
    let(:user) { create(:user) }
    let(:member) { double(mention: '@member') }

    it 'reports when the member has no current RPGotQ completion' do
      expect(described_class.rpg_achievements_message(user, member)).to include("hasn't completed")
    end

    it 'flags the current RPGotQ completion' do
      completion = create(:completion, user:, nomination: create(:nomination, :rpg, :winner))
      user.update!(earned_points: 1)
      expect(described_class.rpg_achievements_message(user, member))
        .to eq('@member has earned 100% achievements on ' \
               "#{completion.game.preferred_name} and been awarded 2 bonus points! They have earned 3.0 total points from GotX.")
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
