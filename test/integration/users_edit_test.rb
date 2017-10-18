require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  # 登録失敗時のテスト
  test "unsuccessful edit" do
    get edit_user_path(@user)

    # users/editとレイアウトが一致していることをテストする
    assert_template('users/edit')

    patch user_path(@user),
    params: {
      user: {
        name:                  "",
        email:                 "user@invalid",
        password:              "foo",
        password_confirmation: "bar"
      }
    }

    

    # エラーメッセージが存在することをテストする
    assert_select('div#error_explanation')
    assert_select('div.alert', 'The form contains 4 errors.')
  end

  # 登録成功時のテスト
  test "successful edit" do
    get edit_user_path(@user)

    # users/editとレイアウトが一致していることをテストする
    assert_template('users/edit')

    # パスワードを変更する必要がない場合はパスワードを入力しなくても
    # 更新が可能であることをテストする
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),
    params: {
      user: {
        name:                  name,
        email:                 email,
        password:              "",
        password_confirmation: ""
      }
    }

    # flashが空でないことをテストする
    assert_not flash.empty?

    # プロフィールページにリダイレクトされることをテストする
    assert_redirected_to @user

    # ユーザー情報を読み込み直す
    @user.reload

    # データベース内のユーザー情報が正しく変更されたことをテストする
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
