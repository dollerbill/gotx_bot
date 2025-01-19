# frozen_string_literal: true

module NominationsHelper
  def winner?(nomination)
    return if Nomination.current_nominations.include?(nomination)

    "<p><strong>Won:</strong> #{nomination.winner? ? 'Yes' : 'No'}</p>".html_safe
  end

  def select_winner(nomination)
    if nomination.winner?
      content_tag(:p, class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-sm font-medium bg-green-100 text-green-800') do
        concat('Winner')
        concat(content_tag(:i, '', class: 'fas fa-crown ml-1'))
      end
    else
      button_to select_winner_nomination_path(nomination), method: :patch, class: 'px-4 py-2 border rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700' do
        concat(content_tag(:i, '', class: 'fas fa-check mr-1'))
        concat('Pick Winner')
      end
    end
  end
end
