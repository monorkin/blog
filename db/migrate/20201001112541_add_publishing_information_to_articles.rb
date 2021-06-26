# frozen_string_literal: true

class AddPublishingInformationToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :publish_at, :datetime
    add_column :articles, :published, :bool, null: false, default: false
  end
end
