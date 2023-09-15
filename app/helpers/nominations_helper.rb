# frozen_string_literal: true

module NominationsHelper
  def winner?(nomination)
    return if Nomination.current_nominations.include?(nomination)

    "<p><strong>Won:</strong> #{nomination.winner? ? 'Yes' : 'No'}</p>".html_safe
  end

  # rubocop:disable Style/StringConcatenation
  def select_winner(nomination)
    return '<p>Already a winner <i class="fas fa-crown"></i></p>'.html_safe if nomination.winner?

    button_to select_winner_nomination_path(nomination), method: :patch, class: 'btn' do
      content_tag(:i, '', class: 'fas fa-check') + ' Pick winner'
    end
    # rubocop:enable Style/StringConcatenation
  end

  def winner_status(nomination)
    nomination.winner ? '<i class="fas fa-crown"></i>'.html_safe : nil
  end
end
