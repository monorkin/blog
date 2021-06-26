# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :tags, id: :uuid do |t|
      t.citext :name

      t.timestamps
    end

    add_index :tags, :name, unique: true
  end
end
