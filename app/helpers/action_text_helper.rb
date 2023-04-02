# frozen_string_literal: true

module ActionTextHelper
  def transform_rich_text(rich_text, transforms: nil)
    if transforms.blank?
      transforms = methods(false)
        .select { |name| name.to_s.ends_with?("_rich_text_transform") }
        .map { |name| name.gsub(/_rich_text_transform$/, "") }
    end

    transforms.reduce(rich_text.dup) do |new_rich_text, transform|
      public_send("#{transform}_rich_text_transform", new_rich_text)
    end
  end

  def highlight_code_blocks_rich_text_transform(rich_text)
    rich_text
  end
end
