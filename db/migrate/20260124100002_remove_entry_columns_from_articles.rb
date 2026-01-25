# frozen_string_literal: true

class RemoveEntryColumnsFromArticles < ActiveRecord::Migration[8.2]
  def up
    remove_index :articles, :slug_id
    remove_index :articles, :published
    remove_index :articles, :published_at

    remove_column :articles, :slug
    remove_column :articles, :slug_id
    remove_column :articles, :published
    remove_column :articles, :published_at
    remove_column :articles, :publish_at
  end

  def down
    add_column :articles, :slug, :text, null: false, default: ""
    add_column :articles, :slug_id, :string, null: false
    add_column :articles, :published, :boolean, null: false, default: false
    add_column :articles, :published_at, :datetime
    add_column :articles, :publish_at, :datetime

    add_index :articles, :slug_id, unique: true
    add_index :articles, :published
    add_index :articles, :published_at

    # Restore data from entries
    execute <<~SQL
      UPDATE articles
      SET slug = entries.slug,
          slug_id = entries.slug_id,
          published = entries.published,
          published_at = entries.published_at,
          publish_at = entries.publish_at
      FROM entries
      WHERE entries.entryable_type = 'Article'
      AND entries.entryable_id = articles.id
    SQL
  end
end
