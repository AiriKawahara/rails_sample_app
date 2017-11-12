class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

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

  # パスワードリセットする場合は以下の4つをチェックする
  # (1) パスワード再設定の有効期限が切れていないか
  # (2) 無効なパスワードであれば失敗させる(失敗した理由も表示する)
  # (3) 新しいパスワードが空文字になっていないか(ユーザー編集ではOKだった)
  # (4) 新しいパスワードが正しければ更新する
  def update
    # (1)はbefore_action(check_expiration)で対応
    if params[:user][:password].empty?
      # (3)への対応
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      # user_paramsはプライベートメソッド
      # (4)への対応
      log_in @user
      # パスワード再設定に成功したらダイジェストをnilにし
      # 同じURLからパスワード再設定を行うことができないようにする
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      # (2)への対応
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

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

    # トークンが期限切れかどうかを確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
