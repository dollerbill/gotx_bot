# frozen_string_literal: true

# == Schema Information
#
# Table name: api_tokens
#
#  id           :bigint           not null, primary key
#  provider     :string           not null
#  access_token :text             not null
#  expires_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class ApiToken < ApplicationRecord
  validates :provider, presence: true, uniqueness: true
  validates :access_token, presence: true

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def self.for_provider(provider)
    find_by(provider: provider)
  end
end
