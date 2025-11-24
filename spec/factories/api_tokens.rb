# frozen_string_literal: true

FactoryBot.define do
  factory :api_token do
    provider { 'igdb' }
    access_token { 'test_token_abc123' }
    expires_at { 1.hour.from_now }
  end
end
