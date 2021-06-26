# frozen_string_literal: true

class CreateArticleStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :article_statistics, id: :uuid do |t|
      t.belongs_to :article,
                   type: :string,
                   foreign_key: { on_delete: :cascade },
                   null: false
      t.bigint :view_count, null: false, default: 0
      t.jsonb :referrer_visit_counts, null: false, default: {}
      t.jsonb :visit_counts_per_month, null: false, default: {}

      t.timestamps
    end
  end
end
