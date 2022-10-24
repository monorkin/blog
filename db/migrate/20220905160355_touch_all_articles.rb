# frozen_string_literal: true

class TouchAllArticles < ActiveRecord::Migration[7.0]
  def up
    execute('UPDATE articles SET updated_at = NOW()')
  end

  def down
  end
end
