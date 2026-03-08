# frozen_string_literal: true

class ReintroduceGalleries < ActiveRecord::Migration[8.2]
  def up
    create_table :galleries do |t|
      t.string :title, null: false
      t.timestamps
    end

    # Create galleries for each distinct gallery name
    execute <<~SQL
      INSERT INTO galleries (title, created_at, updated_at)
      SELECT DISTINCT gallery, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM snaps
      WHERE gallery IS NOT NULL AND gallery != ''
    SQL

    # Create individual galleries for standalone snaps
    execute <<~SQL
      INSERT INTO galleries (title, created_at, updated_at)
      SELECT title, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM snaps
      WHERE gallery IS NULL OR gallery = ''
    SQL

    add_reference :snaps, :gallery, null: true, foreign_key: true

    # Link gallery snaps to their gallery
    execute <<~SQL
      UPDATE snaps
      SET gallery_id = (SELECT id FROM galleries WHERE galleries.title = snaps.gallery)
      WHERE gallery IS NOT NULL AND gallery != ''
    SQL

    # Link standalone snaps to their individual gallery
    execute <<~SQL
      UPDATE snaps
      SET gallery_id = (SELECT id FROM galleries WHERE galleries.title = snaps.title)
      WHERE gallery IS NULL OR gallery = ''
    SQL

    change_column_null :snaps, :gallery_id, false
    remove_column :snaps, :gallery
  end

  def down
    add_column :snaps, :gallery, :string

    execute <<~SQL
      UPDATE snaps
      SET gallery = (SELECT title FROM galleries WHERE galleries.id = snaps.gallery_id)
    SQL

    remove_reference :snaps, :gallery
    drop_table :galleries
  end
end
