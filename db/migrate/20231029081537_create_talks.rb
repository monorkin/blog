class CreateTalks < ActiveRecord::Migration[7.1]
  def change
    create_table :talks do |t|
      t.string :title, null: false
      t.text :event, null: false
      t.text :event_url
      t.text :video_mirror_url
      t.datetime :held_at, null: false

      t.timestamps
    end
  end
end
