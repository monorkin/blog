# frozen_string_literal: true

class Session
  include ActiveModel::Model

  attr_accessor :username,
                :password,
                :one_time_password

  validate :validate_user_exists!
  validate :validate_password_matches!
  validate :validate_one_time_password_matches!

  def user
    @user ||= User.find_by(username: username)
  end

  def password_valid?
    user&.authenticate(password)
  end

  def otp_valid?
    user&.otp_valid?(one_time_password)
  end

  def otp_enabled?
    user&.otp_enabled?
  end

  def otp_unconfirmed?
    user&.otp_unconfirmed?
  end

  def login!
    generate_otp_secret!
    return false unless valid?

    if user.otp_unconfirmed?
      user.otp_secret = user.unconfirmed_otp_secret
      user.unconfirmed_otp_secret = nil
    end

    user.last_otp_used_at = Time.now
    user.last_login_at = Time.now
    user.save!
  end

  private

  def validate_user_exists!
    return if user

    errors.add(:username, 'does not exist')
  end

  def validate_password_matches!
    return unless user
    return if password_valid?

    errors.add(:password, 'does not match this user')
  end

  def validate_one_time_password_matches!
    return unless user
    return if otp_valid?

    errors.add(:one_time_password, 'is invalid')
  end

  def generate_otp_secret!
    return unless user
    return if otp_enabled? || user.otp_unconfirmed?

    user.update!(unconfirmed_otp_secret: ROTP::Base32.random)
  end
end
