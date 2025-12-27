# frozen_string_literal: true

module Articles
  class LinkPreviewsController < ApplicationController
    layout false

    helper_method :url

    def show
      @article = Article.from_slug!(params[:article_slug])
      @link_preview = Article::LinkPreview.for(url: url, article: @article)

      return head :not_found if @link_preview.blank?
      return head :ok if request.head?

      @link_preview.fetch! unless @link_preview.fetched?

      fresh_when(@link_preview)
    end

    def url
      return if params[:id].blank?

      begin
        Base64.urlsafe_decode64(params[:id]).presence
      rescue ArgumentError
        nil
      end
    end
  end
end
