# frozen_string_literal: true

class AddSlugToGalleries < ActiveRecord::Migration[8.2]
  def change
    add_column :galleries, :slug, :string

    Gallery.reset_column_information
    Gallery.find_each { |g| g.update_column(:slug, g.title.parameterize) }

    change_column_null :galleries, :slug, false
    add_index :galleries, :slug, unique: true
  end
end
