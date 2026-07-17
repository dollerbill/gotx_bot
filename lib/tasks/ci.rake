# frozen_string_literal: true

# Runs the same gates as .github/workflows/run_tests.yml, in the same order.
# Keep this list in sync with that workflow.
desc 'Run every CI gate locally (bundler-audit, brakeman, rubocop, rspec)'
# Deliberately does NOT depend on :environment — each gate shells out so specs
# load spec/rails_helper.rb (and its test ENV defaults) before dotenv reads .env.
task :ci do
  gates = {
    'bundler-audit' => 'bundle exec bundler-audit check --update',
    'brakeman' => 'bundle exec brakeman --no-pager --exit-on-warn',
    'rubocop' => 'bundle exec rubocop',
    'rspec' => 'bundle exec rspec'
  }

  # dotenv has already loaded the real .env into this process. Unset the vars the
  # specs set their own defaults for, so rspec sees a CI-like environment.
  test_env = {
    'RAILS_ENV' => 'test',
    'API_TOKEN' => nil,
    'ADMIN_USER_NAMES' => nil,
    'ADMIN_UI_PASSWORD' => nil
  }

  failed = gates.reject do |name, command|
    puts "\n\e[1m==> #{name}\e[0m"
    system(test_env, command)
  end.keys

  puts
  abort("\e[31mFAILED:\e[0m #{failed.join(', ')}") if failed.any?
  puts "\e[32mAll CI gates passed.\e[0m"
end
