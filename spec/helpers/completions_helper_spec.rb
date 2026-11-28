# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompletionsHelper, type: :helper do
  describe '#rpg_achievements_column' do
    let(:completion) { create(:completion, nomination: create(:nomination, :rpg, :winner)) }

    it 'shows the button for the current RPGotQ' do
      expect(helper.rpg_achievements_column(completion)).to include('100% Completed')
    end

    it 'hides the button for a past RPGotQ' do
      past = create(:theme, :rpg, creation_date: Date.current.last_quarter.beginning_of_quarter)
      completion = create(:completion, nomination: create(:nomination, :rpg, :winner, theme: past))
      expect(helper.rpg_achievements_column(completion)).not_to include('100% Completed')
    end

    it 'shows the badge once achieved' do
      completion.update!(rpg_achievements: true)
      expect(helper.rpg_achievements_column(completion)).to include('100% Achievements')
    end
  end
end
