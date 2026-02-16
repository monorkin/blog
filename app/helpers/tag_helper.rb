# frozen_string_literal: true

module TagHelper
  def tag_bubble(tag, **options)
    label = "##{tag.name}"

    link_to(
      label,
      tag_path(tag),
      class: token_list("tag", options[:class])
    )
  end

  def tag_input_field(form, tags: [])
    content_tag(:div, class: "tag-input",
      data: { controller: "tag-input navigable-list",
              tag_input_suggestions_url_value: suggestions_path,
              action: "click@document->tag-input#closeOnClickOutside" }) do
      concat form.hidden_field(:tags, value: tags.join(", "), data: { tag_input_target: "hiddenInput" })
      concat content_tag(:div, class: "tag-input__wrapper",
        data: { action: "click->tag-input#focusInput" }) {
        concat content_tag(:div, "", data: { tag_input_target: "tagList" }, class: "contents")
        concat tag(:input,
          type: "text",
          autocomplete: "off",
          placeholder: tags.empty? ? "Add tags..." : "",
          class: "tag-input__field",
          data: { tag_input_target: "textInput", action: "input->tag-input#search keydown->navigable-list#navigate keydown->tag-input#navigate" })
      }
      concat content_tag(:ul, "",
        class: "tag-input__suggestions hidden",
        data: { tag_input_target: "suggestions" })
    end
  end
end
