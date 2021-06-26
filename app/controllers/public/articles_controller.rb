# frozen_string_literal: true

require 'rss'

module Public
  class ArticlesController < PublicController
    def index
      @paginator = Paginator.decode(
        scope: scope,
        direction: params.key?(:before) ? :before : :after,
        cursor: params[:before] || params[:after]
      )

      @records = @paginator.records

      fresh_when(@records)
    end

    def show
      @record = Article.from_slug!(params[:slug])
      @nexter = Nexter.wrap(scope, @record)

      authorize(@record)
      log_visit(@record)

      fresh_when(@record)
    end

    def atom
      headers['Content-Type'] = 'application/atom+xml'
      render xml: atom_feed.to_xml, layout: false
    end

    def rss
      headers['Content-Type'] = 'application/rss+xml'
      render xml: rss_feed.to_xml, layout: false
    end

    private

    def scope
      policy_scope(Article.published).order(published_at: :desc)
    end

    def atom_feed
      RSS::Maker.make('atom') do |maker|
        maker.channel.id = request.host_with_port
        maker.channel.title = 'Not again | Blog'
        maker.channel.updated = scope.first.published_at.to_time.w3cdtf
        maker.channel.author = 'Stanko K.R.'
        maker.channel.link = atom_public_articles_url
        populate_feed(maker)
      end
    end

    def rss_feed
      RSS::Maker.make('2.0') do |maker|
        maker.channel.id = request.host_with_port
        maker.channel.title = 'Not again | Blog'
        maker.channel.description = 'Stanko K.R. personal blog'
        maker.channel.updated = scope.first.published_at.to_time.w3cdtf
        maker.channel.author = 'Stanko K.R.'
        maker.channel.link = rss_public_articles_url
        populate_feed(maker)
      end
    end

    def populate_feed(maker)
      scope.find_each do |article|
        maker.items.new_item do |item|
          item.title = article.title
          item.link = public_article_url(article.slug)
          item.summary = article.excerpt
          item.updated = article.updated_at.to_time.w3cdtf
        end
      end
    end

    def log_visit(article)
      Article::VisitAnalysisEnqueuer.call(article: article, request: request)
    rescue => e
      nil
    end
  end
end
