# frozen_string_literal: true

class RenameArticleImagesToAttachments < ActiveRecord::Migration[7.0]
  def up
    rename_column :article_images, :image_data, :attachment_data
    rename_table :article_images, :article_attachments
  end

  def down
    rename_table :article_attachments, :article_images
    rename_column :article_images, :attachment_data, :image_data
  end
end
