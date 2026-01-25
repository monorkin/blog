# frozen_string_literal: true

module Articles
  class LinkPreviewsController < ApplicationController
    layout false

    before_action :set_link_preview
    before_action :ensure_link_preview_fetched

    def show
      if request.head?
        return head :ok
      else
        fresh_when(@link_preview)
      end
    end

    private
      def set_link_preview
        url = begin
          Base64.urlsafe_decode64(params[:base64_encoded_url]).presence if params[:base64_encoded_url]
        rescue ArgumentError
          nil
        end

        article = Entry.articles.from_slug!(params[:article_slug]).article
        @link_preview = article.link_previews.find_by_url(url)
      end

      def ensure_link_preview_fetched
        head :not_found unless @link_preview&.fetched?
      end
  end
end
