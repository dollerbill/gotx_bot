# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Do not attach request headers, cookies, or IPs to events.
  # See https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = false
end
