class OptimizeArticleLookup < ActiveRecord::Migration[7.0]
  def change
    add_index :articles, :slug_id, unique: true
    add_index :articles, :published
  end
end
