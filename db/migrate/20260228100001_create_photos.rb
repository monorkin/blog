# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :title, null: false
      t.text :caption
      t.integer :position, default: 0, null: false
      t.references :gallery, foreign_key: true

      t.timestamps
    end
  end
end
