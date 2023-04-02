class AddLoginLockout < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :unconfirmed_otp_secret
    remove_column :users, :otp_secret
    remove_column :users, :last_otp_used_at
    remove_column :users, :last_login_at

    add_column :users, :login_attempted_at, :datetime, default: "NOW()"
    execute("UPDATE users SET login_attempted_at = NOW()")
    change_column_null :users, :login_attempted_at, false
    add_column :users, :login_attempt_count, :integer, null: false, default: 0
  end
end
