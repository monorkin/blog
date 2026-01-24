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
      update!(title: metadata.title, description: metadata.description)
      image.attach(io: metadata.image.file, filename: metadata.image.name, content_type: metadata.image.content_type) if metadata.image.present?
    end
  end
end
