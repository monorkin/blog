# frozen_string_literal: true

class Article < ApplicationRecord
  include ActionView::Helpers::TextHelper
  include Entryable

  has_rich_text :content
  has_many :link_previews, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  after_commit :generate_link_previews, on: [:create, :update]
  after_commit :ensure_entry!, on: [:create]

  scope :published, -> { joins(:entry).merge(Entry.published) }

  def to_param
    entry&.to_param
  end

  def excerpt(length: 300)
    truncate(plain_text, length: length, separator: " ")
  end

  def estimated_reading_time(words_per_minute: 225)
    [ (word_count.to_f / words_per_minute).ceil, 1 ].max.to_i
  end

  def word_count
    plain_text.scan(/\w+/).flatten.count
  end

  def plain_text
    content.body.to_plain_text.gsub(/\[[^\]]*\]/, "")
  end

  def cover_image
    content.body.attachments.compact
      .select { |a| a.respond_to?(:image?) }
      .find(&:image?)
  end

  def related_articles(limit: 5)
    return Article.none unless entry&.tags&.any?

    tag_ids = entry.tags.pluck(:id)

    Article
      .published
      .joins(entry: :taggings)
      .preload(:entry)
      .where.not(id: id)
      .where(tag_taggings: { tag_id: tag_ids })
      .group("articles.id")
      .order(Arel.sql("COUNT(tag_taggings.tag_id) DESC"), Arel.sql("entries.published_at DESC"))
      .limit(limit)
  end

  def previous_article
    return nil unless entry&.published_at

    Article
      .published
      .joins(:entry)
      .preload(:entry)
      .where(entries: { published_at: ...entry.published_at })
      .order("entries.published_at DESC")
      .first
  end

  def next_article
    return nil unless entry&.published_at

    Article
      .published
      .joins(:entry)
      .preload(:entry)
      .where(entries: { published_at: (entry.published_at + 1.second).. })
      .order("entries.published_at ASC")
      .first
  end

  def self.popular(limit: 5)
    published
      .joins(:entry)
      .preload(:entry)
      .order("entries.published_at DESC")
      .limit(limit)
  end

  def generate_link_previews
    active_link_previews = Set.new

    content.body.links.each do |link|
      link_preview = link_previews.find_or_create_by(url: link)
      active_link_previews << link_preview.id
      link_preview.fetch_later
    end

    link_previews.where.not(id: active_link_previews.to_a).destroy_all
  end

  def ensure_entry!
    return if entry.present?

    create_entry!(
      slug: title.parameterize,
      published: false,
      published_at: Time.current
    )
  end
end
