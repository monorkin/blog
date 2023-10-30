# frozen_string_literal: true

module PageHelper
  def paginate(page:, labels: {})
    content_tag(:section,
      class: "flex flex-col sm:flex-row gap-x-6 gap-y-6 justify-center my-6",
      data: { infinite_scroll_target: "paginationControls" },
      id: "pagination"
    ) do
      classes = "text-indigo-600 hover:text-indigo-800 dark:text-yellow-500 dark:hover:text-yellow-400"
      icon_classes = "justify-center"

      unless page.first?
        concat(link_to(url_for(page: params.fetch(:page, 2).to_i - 1), class: classes) do
          text_with_icon(:arrow_long_left, labels.fetch(:previous_page, t('pagination.previous_page')), position: :before, wrapper: { class: icon_classes })
        end)
      end

      unless page.last?
        concat(link_to(url_for(page: page.next_param), data: { infinite_scroll_target: "nextButton" }, class: classes) do
          text_with_icon(:arrow_long_right, labels.fetch(:next_page, t('pagination.next_page')), position: :after, wrapper: { class: icon_classes })
        end)
      end

      content_tag(:template, data: { infinite_scroll_target: "loadingIndicatorTemplate" }) do
        content_tag(:div, class: "flex justify-center") do
          labels.fetch(:loading_more, t("pagination.loading_more"))
        end
      end
    end
  end
end
