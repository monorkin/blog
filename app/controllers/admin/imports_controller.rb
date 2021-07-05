# frozen_string_literal: true

module Admin
  class ImportsController < AdminController
    def new
      @import = Article::Import.new(article: current_article)
    end

    def create
      @import = Article::Import.new(import_params)

      if @import.save
        redirect_to [:admin, @import.article]
      else
        render :new
      end
    end

    private

    def import_params
      params.fetch(:article_import, {})
            .permit(:bundle)
            .merge(article: current_article)
    end

    def current_article
      return unless params[:article_id]

      @current_article ||= scope.from_slug!(params[:article_id])
    end

    def scope
      policy_scope(Article.all)
    end
  end
end
