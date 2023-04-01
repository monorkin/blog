# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  before_action -> { Current.user = User.find_by(id: session[:user_id]) }

  private

  def unauthorized
    redirect_to({ controller: :errors, action: :unauthorized }, status: :see_other)
  end
end
