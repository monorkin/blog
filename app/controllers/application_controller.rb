# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  before_action do
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    ActiveStorage::Current.url_options = Rails.application.default_url_options
  end

  private

  def unauthorized
    redirect_to({ controller: :errors, action: :unauthorized }, status: :see_other)
  end
end
