# frozen_string_literal: true

# every :day, at: '6:00am' do
#   runner '::Memberships::UpdateSubscribers.call'
# end

every 1.month, at: 'start of the month' do
  runner '::Users::AddMonthlyPremiumPoints.call'
end
