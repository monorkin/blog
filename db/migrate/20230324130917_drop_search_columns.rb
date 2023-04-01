# frozen_string_literal: true

class DropSearchColumns < ActiveRecord::Migration[7.0]
  def up
    remove_column :articles, :searchable
  end
end
