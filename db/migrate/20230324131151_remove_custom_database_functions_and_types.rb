# frozen_string_literal: true

class RemoveCustomDatabaseFunctionsAndTypes < ActiveRecord::Migration[7.0]
  def up
    execute "DROP TRIGGER gen_articles_id ON articles;"
    execute "DROP FUNCTION gen_random_shortid();"
    execute "DROP FUNCTION base58_encode(bytea);"
    execute "DROP DOMAIN shortid;"
  end
end
