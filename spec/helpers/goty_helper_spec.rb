# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GotyHelper, type: :helper do
  describe '#next_goty_year' do
    context 'when no GotY themes exist' do
      it 'returns current year' do
        expect(helper.next_goty_year).to eq(Date.current.year)
      end
    end

    context 'when GotY themes exist' do
      before do
        create(:theme, :goty, creation_date: Date.new(2024, 12, 1), title: 'GotY 2024')
      end

      it 'returns the year after the last GotY theme' do
        expect(helper.next_goty_year).to eq(2025)
      end
    end
  end

  describe '#eligible_goty_year' do
    context 'when no GotY themes exist' do
      it 'returns current year (same as next_goty_year)' do
        expect(helper.eligible_goty_year).to eq(Date.current.year)
      end
    end

    context 'when GotY themes exist' do
      before do
        create(:theme, :goty, creation_date: Date.new(2024, 12, 1), title: 'GotY 2024')
      end

      it 'returns the same year as next_goty_year' do
        expect(helper.eligible_goty_year).to eq(2025)
      end
    end
  end

  describe '#goty_theme_exists?' do
    context 'when theme does not exist for the given year' do
      it 'returns false' do
        expect(helper.goty_theme_exists?(2024)).to be false
      end
    end

    context 'when theme exists for the given year' do
      before do
        create(:theme, :goty, creation_date: Date.new(2024, 1, 1), title: 'GotY 2024')
      end

      it 'returns true' do
        expect(helper.goty_theme_exists?(2024)).to be true
      end
    end
  end
end
