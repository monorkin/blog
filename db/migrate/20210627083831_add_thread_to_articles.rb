class AddThreadToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :thread, :string
    add_index :articles, :thread
  end
end
