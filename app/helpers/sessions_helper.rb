module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成される
    # この後のページで、session[:user_id]を使ってユーザーIDを元通りに取り出すことができる
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    # model(user.rb)のrememberメソッドの呼び出し
    user.remember
    #　signedでcookiesの形式が見えないよう署名付きcookiesの使用
    # 記憶トークンとペアで使うためユーザーIDもpermanemtで永続化
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user?(user)
    user == current_user
  end

  # 現在ログイン中のユーザーを返す(ログイン中の場合)
  # ビュー(ヘッダ)から呼び出されている
  def current_user
    # cookiesを設定すると以後のページのビューでcookiesからユーザーを取り出せる
    # User.find_by(id: cookies.signed[:user_id])
    if (user_id = session[:user_id])
      # ユーザーIDにユーザーIDのセッションを代入した結果ユーザーIDのセッションが存在すれば
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # cookies.signed[:user_id]では自動的にユーザーIDの
      # cookiesの暗号が解除され元に戻る
      user = User.find_by(id: user_id)
      # model(user.rb)のauthenticated?メソッドの呼び出し
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in(user)
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    # 明示的にreturn文やメソッドの最終行が呼び出されない限りリダイレクトは発生しない
    # そのためredirect文の後にあるコードも実行される
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく(GETリクエストのみ)
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
