# frozen_string_literal: true

# == Schema Information
# Schema version: 20210125065024
#
# Table name: article_images
#
#  id            :uuid             not null, primary key
#  image_data    :jsonb
#  original_path :text
#  primary       :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  article_id    :string           not null
#
# Indexes
#
#  index_article_images_on_article_id              (article_id)
#  index_article_images_on_article_id_and_primary  (article_id,primary) UNIQUE WHERE ("primary" = true)
#  index_article_images_on_primary                 (primary)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#
class Article
  class Image < ApplicationRecord
    include ImageUploader::Attachment(:image)

    belongs_to :article

    validates :article, presence: true
    validates :image, presence: true
    validates :primary, uniqueness: { scope: :article, if: -> { primary } }

    before_save do
      image_derivatives!
    end

    def srcset
      return [] if derivatives.nil? || derivatives.empty?

      derivatives
        .map { |version, data| [image_url(version), data.dig('metadata', 'width')] }
        .sort_by(&:last)
        .reverse
        .map { |url, width| [url, "#{width}w"] }
    end

    def derivatives
      image_data['derivatives']
    end

    def aspect_ratio
      return if derivatives.blank?

      derivatives
        .map { |_, data| data['metadata'].slice('width', 'height').values.map(&:to_f) }
        .map { |(w, h)| w / h }
        .max
        .round(2)
    end
  end
end
