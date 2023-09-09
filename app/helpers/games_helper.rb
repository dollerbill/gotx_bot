# frozen_string_literal: true

module GamesHelper
  def lazy_hltb(attribute, field)
    content_tag(:p, "<strong>#{field}:</strong> #{attribute} #{'hour'.pluralize(attribute)}".html_safe) if attribute
  end
end
