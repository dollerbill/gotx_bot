# frozen_string_literal: true

module Helpers
  module FuzzySearchHelper
    def set_search_limit
      ActiveRecord::Base.connection.execute('SELECT set_limit(0.25);')
    end
  end
end
