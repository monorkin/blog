class Article::LinkPreview < ApplicationRecord
  FETCHERS = [
    WikipediaFetcher,
    GenericFetcher
  ].freeze

  belongs_to :article
  has_one_attached :image

  normalizes :title, with: -> { it&.strip&.truncate(255) }
  normalizes :description, with: -> { it&.strip&.truncate(1000) }

  def fetch_later
    Article::LinkFetchJob.perform_later(self)
  end

  def fetch
    if fetcher = FETCHERS.find { it.resolves?(url) }
      metadata = fetcher.fetch(url)

      if metadata.present?
        update!(title: metadata.title, description: metadata.description)

        if metadata.image.present?
          image.attach(
            io: metadata.image.file,
            filename: metadata.image.filename,
            content_type: metadata.image.content_type
          )
        end
      end
    end
  end

  def fetched?
    title.present? || description.present?
  end

  def image?
    image.attached?
  end

  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.url_for(image)
    end
  end
end
