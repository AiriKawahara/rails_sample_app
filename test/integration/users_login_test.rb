require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # fixtureのユーザーにアクセス
    @user = users(:michael)
  end

  # フラッシュメッセージの残留をキャッチするテスト
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

  test "login with valid information" do
    # 1.ログイン用のパスを開く
    get login_path
    # 2.セッション用パスに有効な情報をpostする
    post login_path,
    params: {
      session: {
        email:    @user.email,
        password: "password"
      }
    }
    # リダイレクト先が正しいかどうかチェック
    assert_redirected_to @user
    # 指定したリダイレクト先に移動するメソッド
    follow_redirect!
    assert_template 'users/show'
    # 3.ログイン用リンクが表示されなくなったことを確認する
    assert_select "a[href=?]", login_path, count: 0
    # 4.ログアウト用リンクが表示されていることを確認する
    assert_select "a[href=?]", logout_path
    # 5.プロフィール用リンクが表示されていることを確認する
    assert_select "a[href=?]", user_path(@user)
  end
end
