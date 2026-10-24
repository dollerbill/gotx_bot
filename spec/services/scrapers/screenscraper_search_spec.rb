# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scrapers::ScreenscraperSearch do
  describe 'call' do
    let(:body) { File.read(Rails.root.join('spec', 'fixtures', 'screenscraper_search_grandia.json')) }
    let(:atts) { { 'name' => 'grandia' } }

    let(:http) { instance_double(Net::HTTP) }
    let(:http_response) do
      Net::HTTPOK.new('1.1', 200, 'OK').tap { |r| allow(r).to receive(:body).and_return(body) }
    end

    before do
      allow(Net::HTTP).to receive(:new).and_return(http)
      allow(http).to receive(:use_ssl=)
      allow(http).to receive(:open_timeout=)
      allow(http).to receive(:read_timeout=)
      allow(http).to receive(:get).and_return(http_response)
    end

    subject(:results) { described_class.(atts) }

    it 'formats the Screenscraper search results' do
      expect(results).to eq(
        [
          { screenscraper_id: '19289', title: 'Grandia', system: 'Playstation', year: '1997' },
          { screenscraper_id: '13513', title: 'Grandia (Saturn)', system: 'Saturn', year: nil }
        ]
      )
    end

    it 'searches by the encoded name' do
      expect(http).to receive(:get).with(a_string_including('jeuRecherche.php', 'recherche=final+fantasy')).and_return(http_response)
      described_class.('name' => 'final fantasy')
    end

    context 'when no games are found' do
      let(:body) { { response: { jeux: [{}] } }.to_json }

      it 'returns an empty list' do
        expect(results).to eq([])
      end
    end

    context 'when there are more results than the limit' do
      let(:body) { { response: { jeux: Array.new(15) { |i| { id: i.to_s } } } }.to_json }

      it 'returns at most MAX_RESULTS games' do
        expect(results.size).to eq(described_class::MAX_RESULTS)
      end
    end

    context 'when API returns an error in the body' do
      let(:body) { 'API closed' }

      it 'raises ApiUnavailable error' do
        expect { subject }.to raise_error(described_class::ApiUnavailable)
      end
    end

    context 'when API returns a non-JSON body' do
      let(:body) { 'Erreur de login : Verifier vos identifiants developpeur !' }

      it 'raises ApiUnavailable error' do
        expect { subject }.to raise_error(described_class::ApiUnavailable)
      end
    end

    context 'when API returns a non-success HTTP status' do
      let(:http_response) { Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable') }

      it 'raises ApiUnavailable error' do
        expect { subject }.to raise_error(described_class::ApiUnavailable, /503/)
      end
    end

    context 'when the connection times out' do
      before { allow(http).to receive(:get).and_raise(Net::ReadTimeout) }

      it 'raises ApiUnavailable error' do
        expect { subject }.to raise_error(described_class::ApiUnavailable)
      end
    end
  end
end
