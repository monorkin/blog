# frozen_string_literal: true

class AddOtpSecretToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :unconfirmed_otp_secret, :text
    add_column :users, :otp_secret, :text
    add_column :users, :last_otp_used_at, :datetime
    add_column :users, :last_login_at, :datetime
  end
end
