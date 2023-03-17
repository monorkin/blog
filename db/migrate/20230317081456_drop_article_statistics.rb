class DropArticleStatistics < ActiveRecord::Migration[7.0]
  def up
    drop_table :article_statistics
  end
end
