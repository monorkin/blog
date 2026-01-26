# frozen_string_literal: true

class Article < ApplicationRecord
  include Entryable, Pageable, Popular, ReadingTimeEstimatable, Relatable

  content :body

  has_rich_text :body
  has_many :link_previews, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  after_commit :generate_link_previews, on: [ :create, :update ]

  scope :published, -> { joins(:entry).merge(Entry.published) }

  def cover_image
    content.attachments.compact.find do |attachment|
      attachment.respond_to?(:image?) && attachment.image?
    end
  end

  private
    def generate_link_previews
      active_link_previews = Set.new

      content.links.each do |link|
        link_preview = link_previews.find_or_create_by(url: link)
        active_link_previews << link_preview.id
        link_preview.fetch_later
      end

      link_previews.where.not(id: active_link_previews.to_a).destroy_all
    end
end
