class AddLoginLockout < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :unconfirmed_otp_secret, :text
    remove_column :users, :otp_secret, :text
    remove_column :users, :last_otp_used_at, :text
    remove_column :users, :last_login_at, :text

    add_column :users, :login_attempted_at, :datetime, default: "NOW()"
    reversible do |dir|
      dir.up do
        execute("UPDATE users SET login_attempted_at = NOW()")
      end
    end
    change_column_null :users, :login_attempted_at, false
    add_column :users, :login_attempt_count, :integer, null: false, default: 0
  end
end
