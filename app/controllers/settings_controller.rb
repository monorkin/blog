class SettingsController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def index
  end
end
