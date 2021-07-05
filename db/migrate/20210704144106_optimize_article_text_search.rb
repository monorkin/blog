# frozen_string_literal: true

class OptimizeArticleTextSearch < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      ALTER TABLE articles
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', title), 'A') ||
        setweight(to_tsvector('english', content), 'B')
      ) STORED;
    SQL

    add_index :articles, :searchable, using: :gin, algorithm: :concurrently
  end

  def down
    remove_column :articles, :searchable
  end
end
