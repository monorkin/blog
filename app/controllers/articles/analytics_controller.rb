# frozen_string_literal: true

module Articles
  class AnalyticsController < ApplicationController
    def show
      @record = Article.from_slug!(params[:article_slug]).statistic
      fresh_when(@record)
    end
  end
end
