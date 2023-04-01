# frozen_string_literal: true

class ErrorsController < ApplicationController
  after_action -> { request.session_options[:skip] = true }

  def unauthorized
    render status: :unauthorized
  end

  def not_found
    render status: :not_found
  end

  def unprocessable_entity
    render status: :unprocessable_entity
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def unavailable_for_legal_reasons
    render status: :unavailable_for_legal_reasons
  end

  def im_a_teapot
    render status: 418
  end
end
