class LoginController < ApplicationController
  def new
    @login = Login.new
  end

  def create
    @login = Login.new(permitted_params)

    if @login.login
      session[:user_id] = User.first.id
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, status: :see_other
  end

  private

    def permitted_params
      params.require(:login).permit(:username, :password)
    end
end
