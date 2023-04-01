# frozen_string_literal: true

class LoginController < ApplicationController
  def new
    session[:user_id] = User.first.id
    redirect_to root_path, status: :see_other
  end

  def create
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, status: :see_other
  end
end
