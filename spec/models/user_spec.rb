# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  name               :string           not null
#  discord_id         :bigint
#  old_discord_name   :string
#  current_points     :float            default(0.0)
#  redeemed_points    :float            default(0.0)
#  earned_points      :float            default(0.0)
#  premium_points     :float            default(0.0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  premium_subscriber :string
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user, name: 'USERNAME') }
    let(:msg) { 'already exists with this Discord ID' }

    it { is_expected.to validate_uniqueness_of(:discord_id).allow_nil.with_message(msg) }
  end

  it do
    is_expected.to define_enum_for(:premium_subscriber)
      .with_values(supporter: 'supporter', champion: 'champion', legend: 'legend')
      .backed_by_column_of_type(:string)
  end

  describe 'associations' do
    it { is_expected.to have_many :completions }
    it { is_expected.to have_many :nominations }
    it { is_expected.to have_many :streaks }
  end

  describe 'scopes' do
    let!(:new_user)      { create(:user) }
    let!(:top_user)      { create(:user, :legend, earned_points: 999) }
    let!(:mid_user)      { create(:user, earned_points: 90) }
    let!(:low_user)      { create(:user, earned_points: 9) }
    let!(:champion)      { create(:user, :champion) }
    let!(:supporter)     { create(:user, :supporter) }
    let!(:redeemed_user) { create(:user, :redeemed_points) }

    context 'top10' do
      it 'returns the 10 highest points' do
        (1..5).map { |i| create(:user, earned_points: i * 10, name: "User #{i}") }
        expect(User.top10.length).to eq(10)
        expect(User.top10[0..2]).to eq([top_user, redeemed_user, mid_user])
      end
    end

    context 'scores' do
      let(:score_users) { [top_user, redeemed_user, mid_user, low_user] }
      it 'returns users with a name ordered by earned_points in descending order' do
        expect(User.scores[0..3]).to match_array(score_users)
      end
    end

    context 'premium' do
      let(:premium_users) { [top_user, champion, supporter] }
      it 'returns users with a premium subscription' do
        expect(User.premium.to_a).to match_array(premium_users)
      end
    end

    context 'previous_finishers' do
      let(:goty_theme)  { build(:theme, :goty, creation_date: Date.current.last_year.beginning_of_year) }
      let(:rpg_theme)   { build(:theme, :rpg, creation_date: Date.current.last_quarter.beginning_of_quarter) }
      let(:retro_theme) { build(:theme, :retro, creation_date: Date.current.last_week.beginning_of_week) }

      let(:gotm_nom) { build(:nomination, theme: create(:theme, creation_date: Date.current.last_month.beginning_of_month)) }
      let(:goty_nom) { build(:nomination, :goty, theme: goty_theme) }
      let(:rpg_nom) { build(:nomination, :rpg, theme: rpg_theme) }
      let(:retro_nom) { build(:nomination, :retro, theme: retro_theme) }

      let(:gotm_completion)  { create(:completion, nomination: gotm_nom) }
      let(:goty_completion)  { create(:completion, nomination: goty_nom) }
      let(:rpg_completion)   { create(:completion, nomination: rpg_nom) }
      let(:retro_completion) { create(:completion, nomination: retro_nom) }

      let!(:gotm_users)  { [gotm_completion.user] }
      let!(:goty_users)  { [goty_completion.user] }
      let!(:rpg_users)   { [rpg_completion.user] }
      let!(:retro_users) { [retro_completion.user] }

      it 'returns users who have completed the previous theme' do
        expect(User.previous_finishers('gotm').to_a).to match_array(gotm_users)
        expect(User.previous_finishers('goty').to_a).to match_array(goty_users)
        expect(User.previous_finishers('rpg').to_a).to match_array(rpg_users)
        expect(User.previous_finishers('retro').to_a).to match_array(retro_users)
      end
    end
  end
end
