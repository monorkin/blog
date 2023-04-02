# frozen_string_literal: true

# == Schema Information
# Schema version: 20210704144106
#
# Table name: articles
#
#  id           :string           not null, primary key
#  content      :text             default(""), not null
#  publish_at   :datetime
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  searchable   :tsvector
#  slug         :text             default(""), not null
#  thread       :string
#  title        :text             default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_articles_on_published_at  (published_at)
#  index_articles_on_searchable    (searchable) USING gin
#  index_articles_on_thread        (thread)
#
class Article < ApplicationRecord
  include ActionView::Helpers::TextHelper

  has_rich_text :content

  validates :title,
    presence: true
  validates :content,
    presence: true
  validates :slug,
    presence: true
  validates :slug_id,
    presence: true

  before_validation do
    self.slug = title.presence&.parameterize if slug.blank?
    self.generate_slug_id! if slug_id.blank?
  end

  scope(:published, lambda do
    where(published: true).where.not(published_at: (Time.current..))
  end)

  class << self
    def generate_slug_id(length: 12)
      SecureRandom.alphanumeric(length)
    end

    def from_slug(slug)
      from_slug!(slug)
    rescue ActiveRecord::RecordNotFound => _e
      nil
    end

    def from_slug!(slug)
      raise(ActiveRecord::RecordNotFound.new(nil, slug, self, :id)) if slug.blank?

      id = slug.scan(/^.*-([^-]+)$/).flatten.first.presence
      raise(ActiveRecord::RecordNotFound.new(nil, id, self, :id)) if id.blank?

      find_by!(slug_id: id)
    end
  end

  def to_param
    slug
  end

  def slug
    [
      super.presence || title.presence&.parameterize,
      slug_id.presence
    ].compact.join('-').presence
  end

  def published?
    published && published_at <= Time.current
  end

  def excerpt(length: 300)
    truncate(plain_text, length: length)
  end

  def estimated_reading_time(words_per_minute: 325)
    [(word_count.to_f / words_per_minute).ceil, 1].max.to_i
  end

  def word_count
    plain_text.scan(/\w+/).flatten.count
  end

  def plain_text
    content.body.to_plain_text.gsub(/\[[^\]]*\]/, "")
  end

  def html_content
    @_content ||= Content.new(
      content: self[:old_content],
      attachments: Article::Attachment.where(article_id: slug_id)
    )
  end

  def suggested_articles
    Article
      .all
      .published
      .where.not(id: self)
  end

  def generate_slug_id!
    self.slug_id = self.class.generate_slug_id
  end
end
