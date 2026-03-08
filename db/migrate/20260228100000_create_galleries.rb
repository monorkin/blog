# frozen_string_literal: true

class CreateGalleries < ActiveRecord::Migration[8.0]
  def change
    create_table :galleries do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
