# frozen_string_literal: true

module ArticleHelper
  def article_list(articles, **options)
    options[:class] ||= 'flex flex-col divide-y'

    content_tag(:ul, **options) do
      render(articles)
    end
  end
end
