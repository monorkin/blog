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

  def tag_input_field(form, tags: [])
    content_tag(:div, class: "relative",
      data: { controller: "tag-input navigable-list",
              tag_input_suggestions_url_value: suggestions_path,
              action: "click@document->tag-input#closeOnClickOutside" }) do
      concat form.hidden_field(:tags, value: tags.join(", "), data: { tag_input_target: "hiddenInput" })
      concat content_tag(:div, class: "flex flex-wrap items-center gap-1 w-full rounded border border-neutral-300 bg-white dark:text-black px-3 py-2 cursor-text focus-within:border-indigo-500 focus-within:ring-1 focus-within:ring-indigo-500",
        data: { action: "click->tag-input#focusInput" }) {
        concat content_tag(:div, "", data: { tag_input_target: "tagList" }, class: "contents")
        concat tag(:input,
          type: "text",
          autocomplete: "off",
          placeholder: tags.empty? ? "Add tags..." : "",
          class: "flex-1 min-w-[120px] border-0 bg-transparent p-0 focus:ring-0 placeholder:text-gray-400",
          data: { tag_input_target: "textInput", action: "input->tag-input#search keydown->navigable-list#navigate keydown->tag-input#navigate" })
      }
      concat content_tag(:ul, "",
        class: "hidden absolute z-50 mt-1 w-full max-h-48 overflow-y-auto bg-white border border-neutral-300 rounded shadow-lg",
        data: { tag_input_target: "suggestions" })
    end
  end
end
