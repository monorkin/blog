# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  before_action do
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  private

  def unauthorized
    redirect_to({ controller: :errors, action: :unauthorized }, status: :see_other)
  end
end
