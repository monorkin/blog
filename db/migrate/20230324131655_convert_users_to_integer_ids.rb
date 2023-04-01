# frozen_string_literal: true

class ConvertUsersToIntegerIds < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE users DROP CONSTRAINT users_pkey;"
    rename_column :users, :id, :old_id
    execute "CREATE SEQUENCE IF NOT EXISTS users_id_seq AS bigint INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;"
    add_column :users, :id, :primary_key, null: false, default: "nextval('users_id_seq')"
    execute("UPDATE users SET id = -1 * id;")
    execute(
      <<~SQL
        UPDATE users
        SET id = (
          SELECT num
          FROM (
            SELECT ROW_NUMBER () OVER (ORDER BY created_at ASC) AS num, old_id
            FROM users
          ) AS tmp_users
          WHERE tmp_users.old_id = users.old_id
        )
      SQL
    )
    execute "ALTER SEQUENCE users_id_seq OWNED BY users.id;"
    execute "SELECT SETVAL('users_id_seq', (SELECT MAX(id) + 1 FROM users), false);"
    remove_column :users, :old_id
  end
end
