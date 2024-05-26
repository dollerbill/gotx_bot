# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id              :bigint           not null, primary key
#  creation_date   :date             not null
#  title           :string           not null
#  description     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nomination_type :string           default("gotm")
#
require 'rails_helper'

RSpec.describe Theme, type: :model do
  it do
    is_expected.to define_enum_for(:nomination_type)
      .with_values(gotm: 'gotm', rpg: 'rpg', retro: 'retro', goty: 'goty', gotwoty: 'gotwoty')
      .backed_by_column_of_type(:string)
  end

  context 'associations' do
    it { is_expected.to have_many :completions }
    it { is_expected.to have_many :nominations }
  end

  describe 'scopes' do
    context 'current_goty' do
      it 'returns the current_ Thenes' do
      end
    end

    context 'current_rpg' do
      it 'returns the current_ Thenes' do
      end
    end

    context 'current_gotm' do
      it 'returns the current_ Thenes' do
      end
    end

    context 'current_retro' do
      it 'returns the current_ Thenes' do
      end
    end

    context 'most_recent' do
      it 'returns the current_ Thenes' do
      end
    end
  end
end
