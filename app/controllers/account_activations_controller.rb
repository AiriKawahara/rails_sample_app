class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # 有効化が行われるとユーザーはログイン状態となるため
    # 有効化リンクを後から盗みだした人がログインしないよう
    # !user.activate?の条件式が必要となる
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # modelのメソッドの呼び出し
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
