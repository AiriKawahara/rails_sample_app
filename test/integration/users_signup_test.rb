require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path

    # 登録失敗時のテスト
    # テスト実行前後でUser.countが変わらないことをテストする
    assert_no_difference 'User.count' do
      post signup_path,
      params: {
        user: {
          name:                  "",
          email:                 "user@invalid",
          password:              "foo",
          password_confirmation: "bar"
        }
      }
    end

    # users/newとレイアウトが一致していることをテストする
    assert_template('users/new')

    # エラーメッセージをテストする
    assert_select('div#error_explanation')
    assert_select('div.alert')

    # POSTが送信されているURLが正しいことをテストする
    assert_select('form[action="/signup"]')
  end

  test "valid signup information" do
    get signup_path

    # 登録成功時のテスト
    # テスト実行前後でUser.countが1異なることをテストする
    assert_difference 'User.count', 1 do
      post signup_path,
      params: {
        user: {
          name:                  "Example User",
          email:                 "user@example.com",
          password:              "password",
          password_confirmation: "password"
        }
      }
    end
    # POSTリクエストを送信した結果を見て指定したリダイレクト先に移動するメソッド
    follow_redirect!
    # Railsチュートリアル11.2.4で仕様変更のためコメントアウト
    # assert_template('users/show')

    # flashのテスト
    assert_not flash.empty?

    # ユーザー登録の終わったユーザーがログイン状態になっているかテスト
    # Railsチュートリアル11.2.4で仕様変更のためコメントアウト
    # assert is_logged_in?
  end

  # ユーザー登録のテストにアカウント有効化を追加する
  # 本当は"valid signup information"とまとめる
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      # post signup_pathとpost users_pathは同じっぽい
      post users_path,
      params: {
        user: {
          name:                  "Example User",
          email:                 "user@example.com",
          password:              "password",
          password_confirmation: "password"
        }
      }
      # 下の1行がこのテストで最も大事
      # 配信されたメッセージがきっかり1つかどうか確認
      # deliveriesは変数なのでsetupメソッドでこれを初期化しておかないと
      # 並行して行われる他のテストでメールが配信されたときにエラーが発生する
      assert_equal 1, ActionMailer::Base.deliveries.size
      # assignsメソッドを使うと対応するアクション内のインスタンス変数にアクセスできる
      # createアクションで定義された@userというインスタンス変数にアクセス
      user = assigns(:user)
      assert_not user.activated?
      # 有効化していない状態でログインしてみる
      log_in_as(user)
      assert_not is_logged_in?
      # 有効化トークンが不正な場合
      get edit_account_activation_path("invalid token", email: user.email)
      assert_not is_logged_in?
      # トークンは正しいがメールアドレスが無効な場合
      get edit_account_activation_path(user.activation_token, email: "wrong")
      assert_not is_logged_in?
      # 有効化トークンが正しい場合
      get edit_account_activation_path(user.activation_token, email: user.email)
      assert user.reload.activated?
      follow_redirect!
      assert_template 'users/show'
      assert is_logged_in?
    end
  end
end
