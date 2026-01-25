# frozen_string_literal: true

class Entry::SEO
  SITE_NAME = "Stanko K.R."
  SEPARATOR = " | "
  RECOMMENDED_TITLE_MAX_LENGTH = 60
  TITLE_MAX_LENGTH = RECOMMENDED_TITLE_MAX_LENGTH - SITE_NAME.length - SEPARATOR.length
  DESCRIPTION_MAX_LENGTH = 160

  delegate :url_helpers, to: "Rails.application.routes"

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def title
    [
      entry.title.truncate(TITLE_MAX_LENGTH, separator: " "),
      SITE_NAME
    ].join(SEPARATOR)
  end

  def description
    entry.excerpt(length: DESCRIPTION_MAX_LENGTH)
  end

  def canonical_url(**params)
    url_helpers.url_for(entry.entryable, only_path: false, **params)
  end

  def og_type
    "article"
  end

  def image
    @image ||= Image.new(entry)
  end
end

