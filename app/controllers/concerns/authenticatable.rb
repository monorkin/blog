# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  AUTHENTICATION_METHOD_NAME = :authenticate_user!
  CURRENT_USER_SESSION_KEY = :current_user_id

  class_methods do
    def authenticate!(options = nil)
      options ||= {}
      before_action AUTHENTICATION_METHOD_NAME, options
    end

    def skip_authentication_for(*action)
      skip_before_action AUTHENTICATION_METHOD_NAME, on: Array(action)
    end
  end

  included do
    helper_method :current_user

    define_method AUTHENTICATION_METHOD_NAME do
      redirect_to %i[new admin sessions] unless current_user
    end
  end

  def current_user
    @current_user = User.find_by(id: session[CURRENT_USER_SESSION_KEY])
  end

  def login!(user)
    session[CURRENT_USER_SESSION_KEY] = user.id
  end

  def logout!
    session.delete(CURRENT_USER_SESSION_KEY)
  end
end
