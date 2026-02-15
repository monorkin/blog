# frozen_string_literal: true

require "test_helper"

class Article::LinkFetchJobTest < ActiveJob::TestCase
  test "#perform calls fetch on the link preview" do
    article = articles(:misguided_mark)
    link_preview = article.link_previews.create!(url: "https://example.com/test")

    fetched = false
    link_preview.define_singleton_method(:fetch) { fetched = true }

    Article::LinkFetchJob.perform_now(link_preview)

    assert fetched, "Should have called fetch on the link preview"
  end

  test "#perform discards when link preview is deleted" do
    article = articles(:misguided_mark)
    link_preview = article.link_previews.create!(url: "https://example.com/deleted")
    link_preview_id = link_preview.id
    link_preview.destroy!

    assert_nothing_raised do
      perform_enqueued_jobs do
        Article::LinkFetchJob.perform_later(Article::LinkPreview.new(id: link_preview_id))
      end
    end
  end

  test ".perform_later enqueues the job" do
    article = articles(:misguided_mark)
    link_preview = article.link_previews.create!(url: "https://example.com/enqueue")

    assert_enqueued_with(job: Article::LinkFetchJob) do
      Article::LinkFetchJob.perform_later(link_preview)
    end
  end
end
