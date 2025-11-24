# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scrapers::Igdb do
  let(:igdb_response) { File.read(Rails.root.join('spec', 'fixtures', 'igdb_zelda_oracle.json')) }
  let(:parsed_response) { JSON.parse(igdb_response) }
  let!(:theme) { create(:theme, creation_date: Date.current.next_month.beginning_of_month) }
  let(:user) { create(:user) }

  before do
    # Mock access token
    allow_any_instance_of(described_class).to receive(:access_token).and_return('mock_token')
  end

  describe '.call with igdb_id' do
    let(:atts) { { 'igdb_id' => 1032, 'user' => user } }
    let(:http_response) { double('response', code: '200', body: igdb_response) }

    before do
      allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
    end

    subject(:result) { described_class.call(atts) }

    it 'fetches game by ID and formats the response' do
      expect(result[:igdb_id]).to eq(1032)
      expect(result[:title_world]).to eq('The Legend of Zelda: Oracle of Seasons')
      expect(result[:year]).to eq('2001')
      expect(result[:systems]).to eq(['Game Boy Color', 'Nintendo 3DS'])
      expect(result[:genres]).to eq(['Puzzle', 'Role-playing (RPG)', 'Adventure'])
      expect(result[:developer]).to eq('Nintendo')
      expect(result[:img_url]).to eq('https://images.igdb.com/igdb/image/upload/t_720p/sckenj.jpg')
    end

    it 'creates nomination attributes' do
      nominations = result[:nominations_attributes]
      expect(nominations).to be_an(Array)
      expect(nominations.first[:user]).to eq(user)
      expect(nominations.first[:theme]).to eq(theme)
      expect(nominations.first[:description]).to include('Oracle of Seasons')
    end
  end

  describe '.call with game_name' do
    let(:atts) { { 'game_name' => 'Zelda Oracle', 'user' => user } }
    let(:http_response) { double('response', code: '200', body: igdb_response) }

    before do
      allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
    end

    subject(:result) { described_class.call(atts) }

    it 'searches by name and returns best match' do
      expect(result[:igdb_id]).to eq(1032)
      expect(result[:title_world]).to eq('The Legend of Zelda: Oracle of Seasons')
    end
  end

  describe '.call with game_name and platform' do
    let(:atts) { { 'game_name' => 'Zelda', 'platform' => 'Game Boy Color', 'user' => user } }
    let(:http_response) { double('response', code: '200', body: igdb_response) }

    before do
      allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
    end

    subject(:result) { described_class.call(atts) }

    it 'searches with platform filter' do
      expect(result[:igdb_id]).to eq(1032)
      expect(result[:systems]).to include('Game Boy Color')
    end
  end

  describe '.call with both igdb_id and game_name' do
    let(:atts) { { 'igdb_id' => 1032, 'game_name' => 'Zelda', 'user' => user } }
    let(:http_response) { double('response', code: '200', body: igdb_response) }

    before do
      allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
    end

    subject(:result) { described_class.call(atts) }

    it 'prioritizes igdb_id over game_name' do
      expect(result[:igdb_id]).to eq(1032)
    end
  end

  describe 'error handling' do
    context 'when no igdb_id or game_name provided' do
      let(:atts) { { 'user' => user } }

      it 'raises ArgumentError' do
        expect { described_class.call(atts) }.to raise_error(ArgumentError, 'Must provide either igdb_id or game_name')
      end
    end

    context 'when game not found' do
      let(:atts) { { 'igdb_id' => 9999999, 'user' => user } }
      let(:http_response) { double('response', code: '200', body: '[]') }

      before do
        allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
      end

      it 'raises GameNotFound error' do
        expect { described_class.call(atts) }.to raise_error(described_class::GameNotFound)
      end
    end

    context 'when API returns error' do
      let(:atts) { { 'igdb_id' => 1032, 'user' => user } }
      let(:http_response) { double('response', code: '500', body: 'Internal Server Error') }

      before do
        allow(Net::HTTP).to receive(:new).and_return(double('http', use_ssl: true, request: http_response))
        allow_any_instance_of(described_class).to receive(:refresh_access_token)
      end

      it 'raises GameNotFound error with message' do
        expect { described_class.call(atts) }.to raise_error(described_class::GameNotFound, /IGDB API returned 500/)
      end
    end
  end

  describe 'platform mapping' do
    it 'includes common console platforms' do
      expect(described_class::PLATFORM_IDS).to include(
        'Nintendo Switch' => 130,
        'PlayStation 5' => 167,
        'Xbox Series X|S' => 169,
        'Game Boy Color' => 22,
        'SNES' => 19
      )
    end
  end

  describe '#extract_year' do
    let(:service) { described_class.new({}) }

    it 'converts Unix timestamp to year' do
      # 990316800 = May 19, 2001
      expect(service.send(:extract_year, 990316800)).to eq('2001')
    end

    it 'returns nil for missing timestamp' do
      expect(service.send(:extract_year, nil)).to be_nil
    end
  end

  describe '#extract_image_url' do
    let(:service) { described_class.new({}) }

    before do
      service.instance_variable_set(:@igdb_game, parsed_response.first)
    end

    it 'prefers screenshots over cover' do
      url = service.send(:extract_image_url)
      expect(url).to eq('https://images.igdb.com/igdb/image/upload/t_720p/sckenj.jpg')
    end

    it 'adds https prefix' do
      url = service.send(:extract_image_url)
      expect(url).to start_with('https://')
    end

    it 'upgrades to t_720p resolution' do
      url = service.send(:extract_image_url)
      expect(url).to include('t_720p')
      expect(url).not_to include('t_thumb')
    end
  end

  describe '#find_best_match' do
    let(:service) { described_class.new({}) }
    let(:games) do
      [
        { 'name' => 'The Legend of Zelda: Oracle of Seasons' },
        { 'name' => 'The Legend of Zelda: Oracle of Ages' },
        { 'name' => 'Zelda II: The Adventure of Link' }
      ]
    end

    it 'finds exact case-insensitive match' do
      result = service.send(:find_best_match, games, 'the legend of zelda: oracle of seasons')
      expect(result['name']).to eq('The Legend of Zelda: Oracle of Seasons')
    end

    it 'finds partial match when exact not found' do
      result = service.send(:find_best_match, games, 'oracle ages')
      expect(result['name']).to eq('The Legend of Zelda: Oracle of Ages')
    end

    it 'returns first result when no match found' do
      result = service.send(:find_best_match, games, 'mario')
      expect(result['name']).to eq('The Legend of Zelda: Oracle of Seasons')
    end
  end

  describe 'token management' do
    let(:service) { described_class.new({}) }
    let(:token_response) do
      {
        'access_token' => 'new_token_123',
        'expires_in' => 3600
      }.to_json
    end
    let(:http_response) { double('response', is_a?: true, body: token_response) }

    before do
      allow(Net::HTTP).to receive(:post_form).and_return(http_response)
      # Remove the mock to test actual token logic
      allow(service).to receive(:access_token).and_call_original
    end

    it 'creates new token when none exists' do
      expect {
        service.send(:refresh_access_token)
      }.to change(ApiToken, :count).by(1)

      token = ApiToken.for_provider('igdb')
      expect(token.access_token).to eq('new_token_123')
      expect(token.expires_at).to be > Time.current
    end

    it 'updates existing token' do
      create(:api_token, provider: 'igdb', access_token: 'old_token', expires_at: 1.hour.from_now)

      expect {
        service.send(:refresh_access_token)
      }.not_to change(ApiToken, :count)

      token = ApiToken.for_provider('igdb')
      expect(token.access_token).to eq('new_token_123')
    end
  end
end
