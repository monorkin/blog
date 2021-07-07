# frozen_string_literal: true

require 'rss'

module Public
  class ArticlesController < PublicController
    def index
      @search = Article::Search.new(search_params)

      @paginator = Paginator.decode(
        scope: @search.resolve,
        direction: params.key?(:before) ? :before : :after,
        cursor: params[:before] || params[:after]
      )

      @records = @paginator.records

      # Don't cache search results
      fresh_when(@records)
    end

    def show
      @record = Article.from_slug!(params[:slug])

      authorize(@record)
      fresh_when(@record)
      @record.statistic.process_request_later(request)
    end

    def atom
      return(head :internal_server_error) if feed.invalid?

      headers['Content-Type'] = 'application/atom+xml'
      fresh_when(feed.scope)
      render xml: feed.to_atom, layout: false
    end

    def rss
      return(head :internal_server_error) if feed.invalid?

      headers['Content-Type'] = 'application/rss+xml'
      fresh_when(feed.scope)
      render xml: feed.to_rss, layout: false
    end

    private

    def search_params
      params.fetch(:article_search, {})
            .permit(:term, tags: [])
            .merge(scope: scope)
    end

    def scope
      policy_scope(Article.published)
        .order(published_at: :desc)
        .preload(:primary_image)
    end

    def feed
      @feed ||= Article::Feed.new(scope: scope, host: request.host_with_port)
    end
  end
end
