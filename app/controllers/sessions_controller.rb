class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # authenticateメソッドは認証に失敗した時にfalseを返す
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      # flash.nowはレンダリングが終わっているページで特別にフラッシュメッセージを表示することができる
      # その後リクエストが発生した時に消滅する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
  end
end
