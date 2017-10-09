module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成される
    # この後のページで、session[:user_id]を使ってユーザーIDを元通りに取り出すことができる
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す(ログイン中の場合)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
end
