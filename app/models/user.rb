# frozen_string_literal: true

# == Schema Information
# Schema version: 20210125065024
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  last_login_at          :datetime
#  last_otp_used_at       :datetime
#  otp_secret             :text
#  password_digest        :text
#  unconfirmed_otp_secret :text
#  username               :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
class User < ApplicationRecord
  OTP_ISSUER = 'blog.stanko.io'

  has_secure_password

  validates :username, presence: true,
                       uniqueness: true

  def otp_enabled?
    otp_secret.present?
  end

  def otp_unconfirmed?
    unconfirmed_otp_secret.present?
  end

  def otp_valid?(otp)
    return false unless otp.present?

    totp.verify(otp,
                drift_behind: 10.seconds,
                after: last_otp_used_at || 10.minutes.ago)
  end

  def totp_provisioning_uri
    totp.provisioning_uri(username)
  end

  private

  def totp
    ROTP::TOTP.new(unconfirmed_otp_secret || otp_secret, issuer: OTP_ISSUER)
  end
end
