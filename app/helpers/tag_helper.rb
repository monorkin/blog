# frozen_string_literal: true

module TagHelper
  def tag_bubble(tag, **options)
    base_classes = %w[
      px-2 py-1 rounded-full
      transition-colors duration-100 ease-in
      text-xs
      bg-indigo-100 text-indigo-800
      hover:bg-indigo-300 hover:text-indigo-900
      dark:bg-yellow-300 dark:text-neutral-700
      dark:hover:bg-yellow-500 dark:hover:text-neutral-900
    ]

    label = "##{tag.name}"

    link_to(
      label,
      tag_path(tag),
      class: token_list(*base_classes, options[:class])
    )
  end
end
