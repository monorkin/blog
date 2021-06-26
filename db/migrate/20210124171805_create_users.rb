# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.text :username
      t.text :password_digest

      t.timestamps
    end
    add_index :users, :username, unique: true
  end
end
