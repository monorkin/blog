# frozen_string_literal: true

class ArticlesController < ApplicationController
  ORDER = { published_at: :desc, id: :desc }
  RATIOS = [ 10, 20, 30, 50 ]

  def index
    set_page_and_extract_portion_from scope, per_page: RATIOS

    @articles = @page.records

    fresh_when(@articles)
  end

  def show
    @article = Article.from_slug!(params[:slug])

    fresh_when(@article)
  end

  def atom
    return(head :internal_server_error) if feed.invalid?

    headers['Content-Type'] = 'application/atom+xml'

    render xml: feed.to_atom, layout: false
  end

  private

  def scope
    Article
      .all
      .order(ORDER)
      .preload(:primary_image, :attachments)
      .strict_loading
  end

  def feed
    @feed ||= Article::Feed.new(
      scope: scope.preload(:attachments),
      host: request.host_with_port
    )
  end
end
