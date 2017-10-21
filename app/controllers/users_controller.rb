class UsersController < ApplicationController
  # beforeフィルターはbefore_actionメソッドを使って
  # 何らかの処理が実行される直前に特定のメソッドを実行する仕組み
  # boforeフィルタはコントローラ内のすべてのアクションに適用されるので
  # :onlyオプション(ハッシュ)を渡し:editと:updateアクションだけに
  # このフィルタが適用されるよう制限をかけている
  # editアクションとupdateアクションを実行する直前にlogged_in_userアクションを実行させる
  before_action :logged_in_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      # redirect_to user_url(@user)と等価
      redirect_to @user
    else
      # 保存に失敗した場合は登録ページに遷移する
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # 更新に失敗した場合は編集ページに遷移する
      render 'edit'
    end
  end

  private

    def user_params
      params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
    end

    # beforeアクション

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      # session_helperのlogged_in?メソッド
      unless logged_in?
        # ログイン済みでない場合の処理
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
