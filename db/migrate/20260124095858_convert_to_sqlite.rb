# frozen_string_literal: true

class ConvertToSqlite < ActiveRecord::Migration[8.0]
  def up
    # Remove the virtual published_at column and add a regular datetime column
    remove_column :articles, :published_at
    add_column :articles, :published_at, :datetime
    add_index :articles, :published_at

    # Backfill existing data
    execute <<-SQL
      UPDATE articles SET published_at = COALESCE(publish_at, created_at)
    SQL
  end

  def down
    remove_index :articles, :published_at
    remove_column :articles, :published_at

    # Note: Cannot restore PostgreSQL virtual column in SQLite
    # This migration is not fully reversible
  end
end
