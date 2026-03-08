# frozen_string_literal: true

class RefactorPhotosToSnaps < ActiveRecord::Migration[8.0]
  def up
    add_column :photos, :gallery, :string

    execute <<~SQL
      UPDATE photos
      SET gallery = (SELECT galleries.title FROM galleries WHERE galleries.id = photos.gallery_id)
      WHERE photos.gallery_id IS NOT NULL
    SQL

    remove_foreign_key :photos, :galleries
    remove_column :photos, :gallery_id

    rename_table :photos, :snaps

    execute <<~SQL
      UPDATE entries SET entryable_type = 'Snap' WHERE entryable_type = 'Photo'
    SQL

    execute <<~SQL
      DELETE FROM entries WHERE entryable_type = 'Gallery'
    SQL

    drop_table :galleries
  end

  def down
    create_table :galleries do |t|
      t.string :title, null: false
      t.timestamps
    end

    rename_table :snaps, :photos

    add_reference :photos, :gallery, foreign_key: true

    execute <<~SQL
      UPDATE entries SET entryable_type = 'Photo' WHERE entryable_type = 'Snap'
    SQL

    remove_column :photos, :gallery
  end
end
