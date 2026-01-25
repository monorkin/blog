# frozen_string_literal: true

module EntryHelper
  def entry_list(entries, **options)
    options[:class] ||= "flex flex-col divide-y"

    content_tag(:ul, **options) do
      render(entries)
    end
  end
end
