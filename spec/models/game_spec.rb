# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id               :bigint           not null, primary key
#  title_usa        :string
#  title_eu         :string
#  title_jp         :string
#  title_world      :string
#  title_other      :string
#  year             :string
#  systems          :string
#  developer        :string
#  genres           :string
#  img_url          :string
#  time_to_beat     :integer
#  screenscraper_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  igdb_id          :bigint
#
require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :nominations }
  end

  describe '#era' do
    {
      '1985' => :pre96,
      '1995' => :pre96,
      '1996' => :late90s,
      '1999' => :late90s,
      '2000' => :modern,
      '2024' => :modern
    }.each do |year, expected_era|
      it "returns #{expected_era} for year #{year}" do
        expect(build(:game, year:).era).to eq(expected_era)
      end
    end

    it 'returns nil when year is blank' do
      expect(build(:game, year: nil).era).to be_nil
    end
  end

  describe '.in_era' do
    let!(:pre96)   { create(:game, year: '1990') }
    let!(:late90s) { create(:game, year: '1998') }
    let!(:modern)  { create(:game, year: '2010') }

    it { expect(Game.in_era(:pre96)).to contain_exactly(pre96) }
    it { expect(Game.in_era(:late90s)).to contain_exactly(late90s) }
    it { expect(Game.in_era(:modern)).to contain_exactly(modern) }
    it { expect { Game.in_era(:unknown) }.to raise_error(KeyError) }
  end

  describe 'validations' do
    subject { Game.new(attributes) }

    context 'when no title is provided' do
      let(:attributes) { {} }

      it 'is not valid and adds a specific error' do
        expect(subject.valid?).to eq(false)
        expect(subject.errors[:base]).to include('Game must have a title')
      end
    end

    context 'when a title is present' do
      %i[title_usa title_eu title_jp title_world title_other].each do |title|
        let(:attributes) { { title => 'Name' } }

        it 'is valid' do
          expect(subject.valid?).to eq(true)
        end
      end
    end
  end
end
