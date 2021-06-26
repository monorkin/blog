# frozen_string_literal: true

class AddPublishedAtToArticles < ActiveRecord::Migration[6.0]
  def up
    # Rails doesn't currently support virtual columns for Postgres. This is
    # planned to be added to 6.2, for now we have to do it manually.
    execute('ALTER TABLE articles '\
            'ADD COLUMN published_at timestamp(6) without time zone '\
            'GENERATED ALWAYS AS (COALESCE(publish_at, created_at)) STORED')
    add_index :articles, :published_at
  end

  def down
    remove_column :articles, :published_at
  end
end
