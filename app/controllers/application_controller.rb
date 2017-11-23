class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

    # ログイン済みユーザーかどうか確認
    # user_controllerから移動
    def logged_in_user
      # session_helperのlogged_in?メソッド
      unless logged_in?
        # ログイン済みでない場合の処理
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end

