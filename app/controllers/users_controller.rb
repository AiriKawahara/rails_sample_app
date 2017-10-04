class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])    # 実装は終わっていないことに注意
    if @user.save
      # 保存の成功をここで扱う。
    else
      # 保存に失敗した場合は登録ページに遷移する
      render 'new'
    end
  end
end
