# frozen_string_literal: true

module CompletionsHelper
  def rpg_achievements_column(completion)
    if completion.rpg_achievements?
      "100% RetroAchievements #{content_tag(:i, '', class: 'fas fa-check', style: 'color: green;')}".html_safe
    else
      button_to 'Complete', completion_path(completion, completion: { rpg_achievements: true }), method: :patch, class: 'btn btn-outline-primary my-2 my-sm-0'
    end
  end
end
