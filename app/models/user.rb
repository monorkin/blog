# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username,
    presence: true,
    uniqueness: true

  def locked?
    login_attempt_count >= 5
  end

  def unlock!
    with_lock do
      update_columns(login_attempt_count: 0)
    end
  end
end
