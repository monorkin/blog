# frozen_string_literal: true

class AddPrimaryToArticleImages < ActiveRecord::Migration[6.0]
  def change
    add_column :article_images, :primary, :bool, null: false, default: false
    add_index :article_images, :primary
    add_index :article_images, %i[article_id primary],
              unique: true, where: '(article_images.primary = true)'
  end
end
