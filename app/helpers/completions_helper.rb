# frozen_string_literal: true

module CompletionsHelper
  def rpg_achievements_column(completion)
    if completion.rpg_achievements?
      content_tag(:p, class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-sm font-medium bg-green-100 text-green-800') do
        concat('100% Achievements')
        concat(content_tag(:i, '', class: 'fas fa-trophy ml-1'))
      end
    else
      button_to '100% Completed', completion_path(completion, completion: { rpg_achievements: true }), method: :patch, class: 'px-4 py-2 border rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700'
    end
  end
end
