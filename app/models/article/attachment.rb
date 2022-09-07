# frozen_string_literal: true

# == Schema Information
# Schema version: 20220905165144
#
# Table name: article_attachments
#
#  id              :uuid             not null, primary key
#  attachment_data :jsonb
#  original_path   :text
#  primary         :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  article_id      :string           not null
#
# Indexes
#
#  index_article_attachments_on_article_id              (article_id)
#  index_article_attachments_on_article_id_and_primary  (article_id,primary) UNIQUE WHERE ("primary" = true)
#  index_article_attachments_on_primary                 (primary)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#
class Article
  class Attachment < ApplicationRecord
    include AttachmentUploader::Attachment(:attachment)

    belongs_to :article

    validates :attachment,
              presence: true
    validates :primary,
              uniqueness: { scope: :article, if: -> { primary } }

    before_save do
      attachment_derivatives!
    end

    def srcset
      return [] if derivatives.nil? || derivatives.empty?

      derivatives
        .map { |version, data| [attachment_url(version), data.dig('metadata', 'width')] }
        .sort_by(&:last)
        .reverse
        .map { |url, width| [url, "#{width}w"] }
    end

    def image?
      mime_type&.match?(%r{^image/.+$})
    end

    def video?
      mime_type&.match?(%r{^video/.+$})
    end

    def mime_type
      attachment_data.dig('metadata', 'mime_type')
    end

    def derivatives
      attachment_data['derivatives']
    end

    def aspect_ratio
      return if derivatives.blank?

      derivatives
        .map do |_, data|
          width, height = data['metadata'].slice('width', 'height').values
          next if width.blank? || height.blank?

          (width.to_f / height).round(2)
        end
        .compact
        .max
    end
  end
end
