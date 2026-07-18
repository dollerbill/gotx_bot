# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scrapers::Screenscraper do
  describe 'call' do
    # The fixture is double-encoded JSON; parsing once yields the API's raw response body
    let(:body) { JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'screenscraper_grandia.json'))) }
    let(:atts) { { 'screenscraper_id' => '19289' } }
    let!(:theme) { create(:theme, creation_date: Date.current.next_month.beginning_of_month) }

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

    subject(:parsed_response) { described_class.(atts) }

    it 'formats the Screenscraper response' do
      subject
      expect(parsed_response[:title_usa]).to eq('Grandia')
      expect(parsed_response[:nominations_attributes][0][:theme]).to eq(theme)
    end

    it 'sets connection timeouts' do
      expect(http).to receive(:open_timeout=).with(5)
      expect(http).to receive(:read_timeout=).with(10)
      subject
    end

    context 'when API returns an error in the body' do
      let(:body) { 'API closed' }

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

    context 'when screenscraper_id is non-numeric' do
      let(:atts) { { 'screenscraper_id' => 'Pokémon Trading Card Game' } }

      it 'raises GameNotFound before making the request' do
        expect(Net::HTTP).not_to receive(:new)
        expect { subject }.to raise_error(described_class::GameNotFound)
      end
    end
  end
end
