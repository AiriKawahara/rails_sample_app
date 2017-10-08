require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "login with invalid information" do
    # 1.ログイン用のパスを開く
    get login_path
    # 2.新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    # 3.わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path,
    params: {
      session: {
        email:    "",
        password: ""
      }
    }
    # 4.新しいセッションのフォームが再度表示されフラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    # 5.別のページ(Homeページなど)に一旦移動する
    get root_path
    # 6.移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end
end
