# frozen_string_literal: true

class Subscription < ApplicationRecord
  before_create :set_default_start_date

  belongs_to :user

  scope :active, -> { where(end_date: nil) }
  scope :cancelled, -> { where.not(end_date: nil) }
  scope :newly_subscribed, -> { where(subscribed_months: 1, end_date: nil) }

  private

  def set_default_start_date
    self.start_date ||= Date.current.beginning_of_month
  end
end
