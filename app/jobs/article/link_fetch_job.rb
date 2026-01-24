class Article::LinkFetchJob < ApplicationJob
  discard_on ActiveJob::DeserializationError

  def perform(link_preview)
    link_preview.fetch
  end
end
