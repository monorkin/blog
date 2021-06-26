# frozen_string_literal: true

module Admin
  class SessionsController < AdminController
    layout 'login'
    skip_authentication_for :new, :create
    before_action :prevent_double_logins, only: %i[new create]

    def new
      @session = Session.new
    end

    def create
      @session = Session.new(session_params)

      if @session.login!
        login!(@session.user)
        redirect_to admin_root_path
      else
        render :new
      end
    end

    def destroy
      logout!
      redirect_to public_articles_url
    end

    private

    def session_params
      params.fetch(:session, {})
            .permit(:username, :password, :one_time_password)
    end

    def prevent_double_logins
      return unless current_user

      redirect_to admin_root_path
    end
  end
end
