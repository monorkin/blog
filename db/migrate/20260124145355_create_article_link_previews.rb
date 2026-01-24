class CreateArticleLinkPreviews < ActiveRecord::Migration[8.2]
  def change
    create_table :article_link_previews do |t|
      t.belongs_to :article, null: false, foreign_key: true
      t.text :url, null: false
      t.text :title
      t.text :description

      t.timestamps
    end

    add_index :article_link_previews, [:article_id, :url], unique: true
  end
end
