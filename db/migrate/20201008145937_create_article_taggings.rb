# frozen_string_literal: true

class CreateArticleTaggings < ActiveRecord::Migration[6.0]
  def change
    create_table :article_taggings, id: :uuid do |t|
      t.belongs_to :article,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   type: :string
      t.belongs_to :tag,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   type: :uuid

      t.timestamps
    end

    add_index :article_taggings, %i[article_id tag_id], unique: true
  end
end
