# frozen_string_literal: true

class Tag::Tagging < ApplicationRecord
  belongs_to :tag,
             inverse_of: :taggings
  belongs_to :taggable,
             polymorphic: true,
             inverse_of: :taggings

  validates :tag_id,
            uniqueness: { scope: %i[taggable_type taggable_id] }

  after_create do
    tag.touch
    taggable.touch
  end
end
