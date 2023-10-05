# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme, type: :model do
  it do
    is_expected.to define_enum_for(:nomination_type)
      .with_values(gotm: 'gotm', rpg: 'rpg', retro: 'retro', goty: 'goty')
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
