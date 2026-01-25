# frozen_string_literal: true

module Entry::Sluggable
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true
    validates :slug_id, presence: true, uniqueness: true

    before_validation :generate_slug, if: -> { slug.blank? }
    before_validation :generate_slug_id, if: -> { slug_id.blank? }
  end

  class_methods do
    def generate_slug_id(length: 12)
      while candidate = SecureRandom.alphanumeric(length)
        return candidate unless exists?(slug_id: candidate)
      end
    end

    def from_slug(slug)
      from_slug!(slug)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def from_slug!(slug)
      raise ActiveRecord::RecordNotFound.new(nil, slug, self, :slug_id) if slug.blank?

      slug_id = slug.split("-").last.presence
      raise ActiveRecord::RecordNotFound.new(nil, slug_id, self, :slug_id) if slug_id.blank?

      find_by!(slug_id: slug_id)
    end
  end

  def to_param
    [slug, slug_id].compact.join("-").presence
  end

  private
    def generate_slug
      self.slug = title&.parameterize
    end

    def generate_slug_id
      self.slug_id = self.class.generate_slug_id
    end
end
