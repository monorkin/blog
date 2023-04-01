# frozen_string_literal: true

class ChangeArticleIdsToIntegers < ActiveRecord::Migration[7.0]
  def up
    # Remove foreign keys to the articles table
    drop_table :article_taggings
    drop_table :tags

    execute "ALTER TABLE article_attachments DROP CONSTRAINT fk_rails_95824e00d3;"

    # Set a numeric primary key
    execute "ALTER TABLE articles DROP CONSTRAINT articles_pkey;"
    rename_column :articles, :id, :slug_id
    execute "CREATE SEQUENCE IF NOT EXISTS articles_id_seq AS bigint INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;"
    add_column :articles, :id, :primary_key, null: false, default: "nextval('articles_id_seq')"
    execute("UPDATE articles SET id = -1 * id;")
    execute(
      <<~SQL
        UPDATE articles
        SET id = (
          SELECT num
          FROM (
            SELECT ROW_NUMBER () OVER (ORDER BY created_at ASC) AS num, slug_id
            FROM articles
          ) AS tmp_articles
          WHERE tmp_articles.slug_id = articles.slug_id
        )
      SQL
    )
    execute "ALTER SEQUENCE articles_id_seq OWNED BY articles.id;"
    execute "SELECT SETVAL('articles_id_seq', (SELECT MAX(id) + 1 FROM articles), false);"
  end
end
