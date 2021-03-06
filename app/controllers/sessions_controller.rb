class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    # authenticateメソッドは認証に失敗した時にfalseを返す
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        # SessionsHelperのloginメソッドを呼び出しセッションを登録する
        log_in(@user)
        # remember meのチェックボックスにチェックが入っている場合は
        # session_helper.rbのrememberメソッドを呼び出し記憶ダイジェストを登録する
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # ユーザーログイン後にユーザー情報のページにリダイレクトする
        # redirect_to @user
        # ログイン後の遷移先を制御する
        redirect_back_or @user
      else
        # 有効でないユーザーがログインすることのないようにする
        message = "Account not activated."
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # flash.nowはレンダリングが終わっているページで特別にフラッシュメッセージを表示することができる
      # その後リクエストが発生した時に消滅する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # ログイン中のみログアウト処理を行う
    log_out if logged_in?
    redirect_to root_url
  end
end
