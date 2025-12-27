# frozen_string_literal: true

class RemoveDeadCode < ActiveRecord::Migration[7.0]
  def up
    drop_table :article_attachments
    remove_column :articles, :old_content, :text
  end
end
