# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  after_action -> { request.session_options[:skip] = true }

  def current_user
    nil
  end
end
