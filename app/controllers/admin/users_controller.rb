# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    def index
      @q = scope.ransack(params[:q])
      @users = @q.result(distinct: true)
    end

    def show
      @user = scope.find(params[:id])
    end

    def new
      @user = scope.new
    end

    def create
      @user = scope.new(user_params)

      if @user.save
        redirect_to [:admin, @user]
      else
        render :new
      end
    end

    def edit
      @user = scope.find(params[:id])
    end

    def update
      @user = scope.find(params[:id])

      if @user.update(user_params)
        redirect_to [:admin, @user]
      else
        render :edit
      end
    end

    def destroy
      user = scope.find(params[:id])
      user.destroy
      redirect_to action: :index
    end

    private

    def user_params
      params.fetch(:user, {})
            .permit(:username, :password, :password_confirmation)
    end

    def scope
      policy_scope(User.all)
    end
  end
end
