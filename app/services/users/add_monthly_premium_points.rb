# frozen_string_literal: true

module Users
  class AddMonthlyPremiumPoints
    def self.call
      new.call
    end

    def call
      User.supporter.update_all('current_points = current_points + 1, premium_points = premium_points + 1')
      User.champion.update_all('current_points = current_points + 2, premium_points = premium_points + 2')
      User.legend.update_all('current_points = current_points + 3, premium_points = premium_points + 3')
    end
  end
end
