class RenameArticleContentToBody < ActiveRecord::Migration[8.2]
  def up
    ActionText::RichText
      .where(record_type: "Article", name: "content")
      .update_all(name: "body")
  end

  def down
    ActionText::RichText
      .where(record_type: "Article", name: "body")
      .update_all(name: "content")
  end
end
