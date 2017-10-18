require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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
    assert_template('users/show')

    # flashのテスト
    assert_not flash.empty?

    # ユーザー登録の終わったユーザーがログイン状態になっているかテスト
    assert is_logged_in?
  end
end
