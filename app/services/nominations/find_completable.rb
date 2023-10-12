# frozen_string_literal: true

module Nominations
  class FindCompletable
    attr_reader :user, :type, :completions

    def self.call(user, type)
      new(user, type).call
    end

    def initialize(user, type)
      @user = user
      @type = type
      @completions = user.current_completions
    end

    def call
      available = Nomination.public_send("current_#{type}_winners") - completions
      return available unless type == 'goty'

      goty_theme = Theme.goty.find_by('title LIKE ?', "%#{Date.current.last_year.year}%")
      available -= goty_theme.nominations if completions.map(&:theme).include?(goty_theme)
      available
    end
  end
end
