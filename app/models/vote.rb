class Vote < ApplicationRecord
  belongs_to :nomination
  belongs_to :user

  def self.open?
    false
  end
end
