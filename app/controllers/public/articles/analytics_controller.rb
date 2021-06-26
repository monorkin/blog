# frozen_string_literal: true

module Public
  module Articles
    class AnalyticsController < PublicController
      def show
        @record = Article.from_slug!(params[:article_slug]).statistic
      end
    end
  end
end
