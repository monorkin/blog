# frozen_string_literal: true

module PaginationHelper
  def with_automatic_pagination(name, page, &block)
    if page.first?
      content_tag(:div, data: { controller: "pagination" }) do
        capture(&block) + pagination_link(name, page)
      end
    else
      turbo_frame_tag(pagination_frame_id(name, page.number)) do
        capture(&block) + pagination_link(name, page)
      end
    end
  end

  private
    def pagination_link(name, page)
      if page.last?
        "".html_safe
      else
        next_page = page.next_param
        frame_id = pagination_frame_id(name, next_page)

        link_to "Load more",
          url_for(page: next_page),
          class: "block h-px overflow-hidden opacity-0 pointer-events-none",
          data: { pagination_target: "link", turbo_frame: frame_id }
      end
    end

    def pagination_frame_id(name, page_number)
      "#{name}_page_#{page_number}"
    end
end
