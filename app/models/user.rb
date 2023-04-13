# frozen_string_literal: true

class User < ApplicationRecord
  MAX_LOGIN_ATTEMPTS = 5

  has_secure_password

  validates :username,
    presence: true,
    uniqueness: true

  def locked?
    login_attempt_count >= MAX_LOGIN_ATTEMPTS
  end

  def unlock!
    with_lock do
      update_columns(login_attempt_count: 0)
    end
  end
end
