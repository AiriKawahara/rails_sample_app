class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]

  def new
  end

  def create
    # メールアドレスをキーとしてユーザーをデータベースから見つけ出す
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # パスワード再設定用トークンと送信時タイムスタンプでデータベースの属性を更新
      @user.create_reset_digest
      @user.send_password_reset_email
      # ルートURLにリダイレクトしフラッシュメッセージをユーザーに表示
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      # 送信が無効な場合はログインと同様にnewページを出力してflash.nowメッセージを表示
      # flash.nowはレンダリングが終わっているページに特別にメッセージを表示
      # その後リクエスト発生時に消滅
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  private

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      # @user.authenticated?はUserモデルのメソッド
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
end
