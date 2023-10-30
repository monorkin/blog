class Tag < ApplicationRecord
  has_many :taggings,
    class_name: "Tag::Tagging",
    inverse_of: :tag,
    dependent: :destroy

  normalizes :name, with: -> { _1.strip.downcase.gsub(/[^0-9a-z]/, "-").gsub(/-+/, "-").gsub(/^-|-$/, "") }

  validates :name,
    presence: true,
    uniqueness: true
end
