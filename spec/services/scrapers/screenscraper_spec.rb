# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scrapers::Screenscraper do
  describe 'call' do
    let(:response) { File.read(Rails.root.join('spec', 'fixtures', 'screenscraper_grandia.json')) }
    let(:atts) { { 'screenscraper_id' => '19289' } }
    let!(:theme) { create(:theme, creation_date: Date.current.next_month.beginning_of_month) }

    before { allow(Net::HTTP).to receive(:get).and_return(JSON.parse(response)) }

    subject(:parsed_response) { described_class.(atts) }

    it 'formats the Screenscraper response' do
      subject
      expect(parsed_response[:title_usa]).to eq('Grandia')
      expect(parsed_response[:nominations_attributes][0][:theme]).to eq(theme)
    end

    context 'when API returns an error' do
      let(:error) { 'API closed' }

      before { allow(Net::HTTP).to receive(:get).and_return(error) }

      it 'raises GameNotFound error' do
        expect { subject }.to raise_error(described_class::GameNotFound)
      end
    end
  end
end
