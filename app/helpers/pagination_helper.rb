# frozen_string_literal: true

module PaginationHelper
  def pagy_container(&block)
    content_tag(:div, class: 'mt-4 flex items-center justify-between', &block)
  end

  def render_pagination(pagy)
    pagy_container do
      content_tag(:div, class: 'hidden sm:flex-1 sm:flex sm:items-center sm:justify-between') do
        concat(render_pagination_info(pagy))
        concat(render_pagination_nav(pagy))
      end
    end
  end

  private

  def render_pagination_info(pagy)
    content_tag(:div, class: 'flex-1 flex items-center') do
      content_tag(:p, class: 'text-sm text-gray-700') do
        concat('Showing ')
        concat(content_tag(:span, class: 'font-medium') { pagy.from.to_s })
        concat(' to ')
        concat(content_tag(:span, class: 'font-medium') { pagy.to.to_s })
        concat(' of ')
        concat(content_tag(:span, class: 'font-medium') { pagy.count.to_s })
        concat(' results')
      end
    end
  end

  def render_pagination_nav(pagy)
    content_tag(:div, class: 'ml-4') do
      raw(pagy_nav(pagy))
    end
  end
end
