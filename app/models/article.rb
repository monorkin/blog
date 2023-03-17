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

  has_one :primary_image,
          -> { where(primary: true) },
          class_name: 'Article::Attachment'

  has_many :attachments,
           class_name: 'Article::Attachment',
           dependent: :destroy
  has_many :taggings,
           class_name: 'Article::Tagging',
           dependent: :destroy
  has_many :tags,
           through: :taggings

  # validates :id, short_id: true
  validates :title,
            presence: true
  validates :content,
            presence: true

  scope(:published, lambda do
    where(published: true).where.not(published_at: (Time.current..))
  end)

  def self.from_slug(slug)
    from_slug!(slug)
  rescue ActiveRecord::RecordNotFound => _e
    nil
  end

  def self.from_slug!(slug)
    raise(ActiveRecord::RecordNotFound.new(nil, slug, self, :id)) if slug.blank?

    id = slug.scan(/^.*-([^-]+)$/).flatten.first.presence
    raise(ActiveRecord::RecordNotFound.new(nil, id, self, :id)) if id.blank?

    find(id)
  end

  def to_param
    slug
  end

  def slug
    [
      super.presence || title.presence&.parameterize,
      id.presence
    ].compact.join('-').presence
  end

  def published?
    published && published_at <= Time.current
  end

  def excerpt(length: 300)
    truncate(content.to_text.sub(title, ''), length: length)
  end

  def content
    @_content ||= Content.new(content: super, attachments: attachments)
  end

  def content=(new_value)
    super(new_value)
    @_content = nil
    content
  end

  def suggested_articles
    Article
      .all
      .published
      .where.not(id: self)
  end
end
