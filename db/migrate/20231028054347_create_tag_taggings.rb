# frozen_string_literal: true

class CreateTagTaggings < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_taggings do |t|
      t.belongs_to :tag, null: false, foreign_key: true
      t.belongs_to :taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :tag_taggings, %i[taggable_type taggable_id tag_id], unique: true
  end
end
