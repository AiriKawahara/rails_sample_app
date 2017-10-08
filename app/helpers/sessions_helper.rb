module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成される
    # この後のページで、session[:user_id]を使ってユーザーIDを元通りに取り出すことができる
    session[:user_id] = user.id
  end
end
