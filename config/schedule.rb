# frozen_string_literal: true

every 1.month, at: 'start of the month' do
  runner '::Users::AddMonthlyPremiumPoints.call'
end
