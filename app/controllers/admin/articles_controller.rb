# frozen_string_literal: true

module Admin
  class ArticlesController < AdminController
    def index
      @q = scope.ransack(params[:q])
      @articles = @q.result(distinct: true)
    end

    def show
      @article = scope.find(params[:id])
    end

    def destroy
      article = scope.find(params[:id])

      if article.destroy
        redirect_to action: :index
      else
        redirect_back fallback_location: [:admin, article]
      end
    end

    private

    def scope
      policy_scope(Article.all)
    end
  end
end
