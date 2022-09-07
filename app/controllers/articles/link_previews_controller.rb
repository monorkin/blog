# frozen_string_literal: true

module Articles
  class LinkPreviewsController < ApplicationController
    layout false

    helper_method :id
    helper_method :url

    def show
      @record = Article.from_slug!(params[:article_slug])

      return(head :not_found) unless Article::LinkPreview.id_matches_url?(id: id, url: url)
      return(head :ok) if request.head?

      @link_preview = Article::LinkPreview.new(id: id, url: url)

      fresh_when(@link_preview)
    end

    def id
      params[:id]
    end

    def url
      return if params[:url].blank?

      Base64.decode64(params[:url])
    end
  end
end
