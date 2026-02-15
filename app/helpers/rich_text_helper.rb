# frozen_string_literal: true

module RichTextHelper
  def transform_rich_text(rich_text, transforms: nil)
    if transforms.blank?
      transforms = methods
                   .select { |name| name.to_s.ends_with?("_rich_text_transform") }
                   .map { |name| name.to_s.gsub(/_rich_text_transform$/, "") }
    end

    document = Nokogiri.HTML(rich_text.to_s)

    transforms.reduce(document) do |doc, transform|
      public_send("#{transform}_rich_text_transform", doc)
    end.to_s
  end

  # Makes code blocks look prettier / more readable
  def highlight_code_blocks_rich_text_transform(document)
    document.css("pre, code[data-language]").each do |code_block|
      language_tag = code_block["language"].presence ||
                     code_block["data-language"].presence ||
                     code_block.at_css("code[data-language]")&.[]("data-language").presence

      next unless language_tag

      lexer = Rouge::Lexer.find(language_tag)
      next unless lexer

      code_block.css("br").each { |br| br.replace("\n") }
      code = code_block.text

      formatter = Rouge::Formatters::HTML.new
      code_block.inner_html = formatter.format(lexer.lex(code))
      code_block["class"] = [ code_block["class"], "highlight" ].select(&:present?).join(" ")
    end

    document
  end

  def rich_text_field(form, name)
    content_tag(
      :div,
      class: "rich-text",
      data: {
        controller: "rich-text",
        rich_text_ready_class: "rich-text--ready",
        rich_text_loading_class: "rich-text--loading"
      }
    ) do
      form.rich_text_area(
        name,
        data: {
          action: "lexxy:initialize->rich-text#editorReady",
          rich_text_target: "editor"
        }
      )
    end
  end
end
