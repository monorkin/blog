# frozen_string_literal: true

class CreateEntries < ActiveRecord::Migration[8.2]
  def change
    create_table :entries do |t|
      t.text :slug, null: false, default: ""
      t.string :slug_id, null: false
      t.boolean :published, null: false, default: false
      t.datetime :published_at
      t.datetime :publish_at

      t.references :entryable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :entries, :slug_id, unique: true
    add_index :entries, :published
    add_index :entries, :published_at
  end
end
