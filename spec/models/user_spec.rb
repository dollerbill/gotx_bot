# frozen_string_literal: true

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

  context 'associations' do
    it { is_expected.to have_many :completions }
    it { is_expected.to have_many :nominations }
    it { is_expected.to have_many :streaks }
  end

  xdescribe 'scopes' do
    let!(:new_user) { create(:user) }
    let!(:top_user) { create(:user, :current_points, :legend, current_points: 999) }
    let!(:mid_user) { create(:user, :current_points, current_points: 90) }
    let!(:low_user) { create(:user, :current_points, current_points: 9) }
    let!(:champion) { create(:user, :champion) }
    let!(:supporter) { create(:user, :supporter) }
    let!(:redeemed_user) { create(:user, :redeemed_points) }

    context 'top10' do
      it 'returns the 10 highest points' do
        users = Array.new(12) { |i| create(:user, name: "User#{i + 4}", earned_points: (i + 1) * 10) }
        top_10 = users.sort_by(&:earned_points).reverse.first(10)

        expect(User.top10.to_a).to match_array([top_user, mid_user, low_user] + top_10)

        # (1..15).each do |num|
        #   User.create(name: num, earned_points: num)
        # end
        # 5.times { User.create(name: rand(5), earned_points: 25) }
        # expect(User.top10.count).to eq(10)
      end
    end

    context 'scores' do
      let(:score_users) { [top_user, redeemed_user, mid_user, low_user] }
      it 'returns users with a name ordered by earned_points in descending order' do
        expect(User.scores.to_a).to match_array(score_users)
      end
    end

    context 'premium' do
      let(:premium_users) { [top_user, champion, supporter] }
      it 'returns users with a premium subscription' do
        expect(User.premium.to_a).to match_array(premium_users)
      end
    end

    context 'previous_finishers' do
      it '' do
      end
    end
  end
end
