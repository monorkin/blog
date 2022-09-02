# frozen_string_literal: true

class ArticlesController < ApplicationController
  def index
    @paginator = Paginator.decode(
      scope: scope.published,
      direction: params.key?(:before) ? :before : :after,
      cursor: params[:before] || params[:after]
    )

    @popular_articles = Article.sorted_by_popularity.limit(2)
    @articles = @paginator.records

    fresh_when(@articles)
  end

  def show
    @article = Article.from_slug!(params[:slug])

    fresh_when(@article)

    visit = Article::Statistic::Visit.new(article: @article, request: request)
    LogArticleVisitJob.perform_later(@article, visit.to_h)
  end

  def atom
    return(head :internal_server_error) if feed.invalid?

    headers['Content-Type'] = 'application/atom+xml'

    render xml: feed.to_atom, layout: false
  end

  private

  def scope
    Article.all.order(published_at: :desc).preload(:primary_image)
  end

  def feed
    @feed ||= Article::Feed.new(scope: scope, host: request.host_with_port)
  end
end
