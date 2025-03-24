# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games API', type: :request do
  let(:gotm_theme)    { build(:theme) }
  let(:goty_theme)    { build(:theme, :goty, title: "goty #{Date.current.last_year.year}") }
  let(:gotwoty_theme) { build(:theme, :gotwoty, title: "gotwoty #{Date.current.last_year.year}") }
  let(:rpg_theme)     { build(:theme, :rpg) }
  let(:retro_theme)   { build(:theme, :retro) }

  let!(:gotm)    { create(:nomination, :winner, theme: gotm_theme) }
  let!(:rpg)     { create(:nomination, :winner, :rpg, theme: rpg_theme) }
  let!(:retro)   { create(:nomination, :winner, :retro, theme: retro_theme) }

  before { get api_v1_current_winners_path, headers: }

  describe 'unauthorized' do
    let(:headers) { {} }
    it 'returns a 403 response' do
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'authorized' do
    let(:headers) { { 'HTTP_AUTHORIZATION' => 'Bearer TEST' } }

    it 'returns a 200 response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of current GOTX games' do
      expect(response).to be_successful
      body = JSON.parse(response.body)
      response_names = body.flat_map { |_k, v| v }.pluck('name')
      existing_names = [rpg, retro, gotm].flat_map { _1.game.preferred_name }
      expect(body.keys).to contain_exactly('GotM', 'RPGotQ', 'Retro Bit')
      expect(response_names).to eq(existing_names)
    end
  end
end
