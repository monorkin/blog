# frozen_string_literal: true

class Article
  class SEODecorator < ApplicationDecorator
    def title
      [truncate(object.title, length: 60), 'Stanko K.R.'].join(' | ')
    end

    def excerpt
      object.excerpt(length: 160)
    end
  end
end
