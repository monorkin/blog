# frozen_string_literal: true

class MigrateToEntries < ActiveRecord::Migration[8.2]
  def up
    # Migrate existing articles to entries
    execute <<~SQL
      INSERT INTO entries (slug, slug_id, published, published_at, publish_at, entryable_type, entryable_id, created_at, updated_at)
      SELECT slug, slug_id, published, published_at, publish_at, 'Article', id, created_at, updated_at
      FROM articles
    SQL

    # Migrate existing talks to entries
    # Talks don't have publishing workflow - auto-publish them
    # Generate slug_id using a combination of 'talk' prefix and the talk id
    Talk.find_each do |talk|
      Entry.create!(
        slug: talk.title.parameterize,
        slug_id: SecureRandom.alphanumeric(12),
        published: true,
        published_at: talk.held_at,
        publish_at: nil,
        entryable: talk
      )
    end

    # Update taggings to point to Entry instead of Article
    execute <<~SQL
      UPDATE tag_taggings
      SET taggable_type = 'Entry',
          taggable_id = (
            SELECT entries.id
            FROM entries
            WHERE entries.entryable_type = 'Article'
            AND entries.entryable_id = tag_taggings.taggable_id
          )
      WHERE taggable_type = 'Article'
    SQL
  end

  def down
    # Restore taggings to point back to Article
    execute <<~SQL
      UPDATE tag_taggings
      SET taggable_type = 'Article',
          taggable_id = (
            SELECT entries.entryable_id
            FROM entries
            WHERE entries.id = tag_taggings.taggable_id
            AND entries.entryable_type = 'Article'
          )
      WHERE taggable_type = 'Entry'
    SQL

    # Delete all entries
    execute "DELETE FROM entries"
  end
end
