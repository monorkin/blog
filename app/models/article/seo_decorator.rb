# frozen_string_literal: true

class Article
  class SEODecorator < ApplicationDecorator
    def title
      [truncate(object.title, length: 60), 'Stanko K.R.'].join(' | ')
    end

    def excerpt
      truncate(object.content.to_text, length: 160)
    end
  end
end
