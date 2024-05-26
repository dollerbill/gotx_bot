# frozen_string_literal: true

# == Schema Information
#
# Table name: completions
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime         not null
#  nomination_id :bigint
#  user_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe Completion, type: :model do
  subject { build(:completion) }

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :nomination }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:theme).to(:nomination) }
  end

  context 'validations' do
    it do
      is_expected.to validate_uniqueness_of(:user_id)
        .scoped_to(:nomination_id)
        .with_message('has already completed this nomination')
    end
  end

  describe 'scopes' do
    let(:gotm_theme)  { build(:theme, creation_date: Date.current.last_month.beginning_of_month) }
    let(:goty_theme)  { build(:theme, nomination_type: :goty, creation_date: Date.current.last_year.beginning_of_year) }
    let(:rpg_theme)   { build(:theme, nomination_type: :rpg, creation_date: Date.current.last_quarter.beginning_of_quarter) }
    let(:retro_theme) { build(:theme, nomination_type: :retro, creation_date: Date.current.last_week.beginning_of_week) }

    let!(:gotm)  { create(:completion, nomination: build(:nomination, theme: gotm_theme)) }
    let!(:goty)  { create(:completion, nomination: build(:nomination, :goty, theme: goty_theme)) }
    let!(:rpg)   { create(:completion, nomination: build(:nomination, :rpg, theme: rpg_theme)) }
    let!(:retro) { create(:completion, nomination: build(:nomination, :retro, theme: retro_theme)) }

    context 'previous_completions' do
      it 'returns completions for previous themes' do
        expect(Completion.previous_completions('gotm').count).to eq(1)
        expect(Completion.previous_completions('goty').count).to eq(1)
        expect(Completion.previous_completions('rpg').count).to eq(1)
        expect(Completion.previous_completions('retro').count).to eq(1)
      end
    end
  end
end
