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
#  system           :string
#  developer        :string
#  genre            :string
#  img_url          :string
#  time_to_beat     :integer
#  screenscraper_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :nominations }
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
