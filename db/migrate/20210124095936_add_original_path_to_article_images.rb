# frozen_string_literal: true

class AddOriginalPathToArticleImages < ActiveRecord::Migration[6.0]
  def change
    add_column :article_images, :original_path, :text
  end
end
