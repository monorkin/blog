# frozen_string_literal: true

class ApplicationController < ActionController::Base
  etag { Current.user&.id }

  before_action do
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    Current.settings = Settings.new(cookies.to_h.slice('color_scheme'))
    ActiveStorage::Current.url_options = Rails.application.default_url_options
  end

  private

  def unauthorized
    redirect_to({ controller: :errors, action: :unauthorized }, status: :see_other)
  end
end
