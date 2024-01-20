# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'discordrb', git: 'https://github.com/shardlab/discordrb.git', ref: 'main'
gem 'dotenv-rails'
gem 'kaminari'
gem 'pg', '~> 1.1'
gem 'puma', '~> 6.0'
gem 'rails', '~> 6.1.7.5'
gem 'textacular', '~> 5.0'

group :ci do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 6.1.0'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'whenever', require: false
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 5.3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
