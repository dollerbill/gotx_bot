# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rack::Attack throttling' do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after { Rack::Attack.enabled = false }

  it 'throttles repeated requests to the admin UI' do
    21.times { get root_path }
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'throttles repeated requests to the API' do
    61.times { get api_v1_current_winners_path }
    expect(response).to have_http_status(:too_many_requests)
  end
end
