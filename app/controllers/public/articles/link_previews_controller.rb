# frozen_string_literal: true

module Public
  module Articles
    class LinkPreviewsController < PublicController
      layout false

      helper_method :id
      helper_method :url

      def show
        @record = Article.from_slug!(params[:article_slug])

        return(head :not_found) unless @record.content.valid_link?(url, id)

        @link_preview = Rails.cache.fetch(link_preview_cache_key) do
          Article::LinkPreview.new(url: url)
        end

        return(head :not_found) unless @link_preview.valid?
        return(head :ok) if request.head?

        fresh_when(@link_preview)
      end

      def link_preview_cache_key
        return unless @record

        "article/#{@record.id}/link_preview/#{id}"
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
end
