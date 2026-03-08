# frozen_string_literal: true

class RemoveGalleries < ActiveRecord::Migration[8.2]
  def up
    remove_foreign_key :snaps, :galleries
    remove_column :snaps, :gallery_id
    remove_column :snaps, :position
    drop_table :galleries
  end

  def down
    create_table :galleries do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.timestamps
      t.index :slug, unique: true
    end

    add_column :snaps, :gallery_id, :integer, null: false
    add_column :snaps, :position, :integer, null: false, default: 0
    add_index :snaps, :gallery_id
    add_foreign_key :snaps, :galleries
  end
end
