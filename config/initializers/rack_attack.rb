# frozen_string_literal: true

# Throttle admin UI basic-auth attempts
Rack::Attack.throttle('admin_ui/ip', limit: 20, period: 1.minute) do |req|
  req.ip if req.path == '/'
end

# Throttle token-authenticated API requests
Rack::Attack.throttle('api/ip', limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api/')
end

# Disabled in test so request specs aren't throttled; enabled per-example where needed
Rack::Attack.enabled = !Rails.env.test?
