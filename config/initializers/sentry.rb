# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://6083e957bfbbe17cce139ff97e9abc15@o4510904595447808.ingest.us.sentry.io/4510904599052288'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end
