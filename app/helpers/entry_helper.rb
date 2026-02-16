# frozen_string_literal: true

module EntryHelper
  def entry_list(entries, page: nil, **options)
    options[:class] ||= "entry-list"

    if page
      options[:class] += " timeline--first" if page.first?
      options[:class] += " timeline--last" if page.last?
    end

    content_tag(:ul, **options) do
      render(entries)
    end
  end
end
