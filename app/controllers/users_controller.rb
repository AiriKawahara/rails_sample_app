class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)    # 実装は終わっていないことに注意
    if @user.save
      # redirect_to user_url(@user)と等価
      redirect_to @user
    else
      # 保存に失敗した場合は登録ページに遷移する
      render 'new'
    end
  end

  private

    def user_params
      params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
    end
end
