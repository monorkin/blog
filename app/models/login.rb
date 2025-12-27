# frozen_string_literal: true

class Login < ApplicationModel
  attr_accessor :username, :password, :user

  validate :validate_user_exists!
  validate :validate_password_matches_user!

  before_validation do
    find_user! if user.blank?
  end

  def login
    find_user!

    if user&.locked?
      errors.add(:username, :locked)
      return false
    end

    user.unlock! if user.present? && user.login_attempted_at.before?(30.minutes.ago)

    if login_attempts_exceeded?
      errors.add(:username, :locked)
      return false
    end

    if valid?
      user.unlock!
      return true
    end

    record_login_attempt!

    false
  end

  def find_user!
    self.user = User.find_by(username: username)
  end

  def login_attempts_exceeded?
    return false if user.blank?

    user.with_lock do
      user.reload
      user.locked?
    end
  end

  def record_login_attempt!
    return if user.blank?

    user.with_lock do
      user.reload
      user.increment!(:login_attempt_count, 1, touch: :login_attempted_at)
    end
  end

  def validate_user_exists!
    return if user.present?

    errors.add(:username, :unknown)
  end

  def validate_password_matches_user!
    return if user&.authenticate(password)

    errors.add(:password, :invalid)
  end
end
