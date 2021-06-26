# frozen_string_literal: true

class CreateArticleImages < ActiveRecord::Migration[6.0]
  def change
    create_table :article_images, id: :uuid do |t|
      t.jsonb :image_data
      t.belongs_to :article,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   type: :string

      t.timestamps
    end
  end
end
