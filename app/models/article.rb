# frozen_string_literal: true

# == Schema Information
# Schema version: 20210125065024
#
# Table name: articles
#
#  id           :string           not null, primary key
#  content      :text             default(""), not null
#  publish_at   :datetime
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  slug         :text             default(""), not null
#  title        :text             default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_articles_on_published_at  (published_at)
#
class Article < ApplicationRecord
  include ActionView::Helpers::TextHelper

  has_one :statistic,
          class_name: 'Article::Statistic',
          dependent: :destroy
  has_one :primary_image,
          -> { where(primary: true) },
          class_name: 'Article::Image'

  has_many :images,
           class_name: 'Article::Image',
           dependent: :destroy
  has_many :taggings,
           class_name: 'Article::Tagging',
           dependent: :destroy
  has_many :tags, through: :taggings

  default_scope do
    order(published: :desc, published_at: :desc, title: :asc)
  end

  scope(:published, lambda do
    where(published: true).where('published_at <= NOW()')
  end)

  # validates :id, short_id: true
  validates :title, presence: true
  validates :content, presence: true

  def self.from_slug(slug)
    from_slug!(slug)
  rescue ActiveRecord::RecordNotFound => _e
    nil
  end

  def self.from_slug!(slug)
    raise(ActiveRecord::RecordNotFound, nil, slug, self, :id) unless slug.present?

    id = slug.scan(/^.*-([^-]+)$/).flatten.first.presence
    raise(ActiveRecord::RecordNotFound, nil, id, self, :id) unless id

    find(id)
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
    truncate(content.to_text, length: length)
  end

  def content
    @_content ||= ContentDecorator.new(super, self)
  end

  def content=(new_value)
    super(new_value)
    @_contents = nil
    content
  end

  def simmilar_articles(count = 2)
    Article.published.where.not(id: self).order(published_at: :desc).limit(count)
  end
end
