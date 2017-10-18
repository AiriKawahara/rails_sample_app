require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  # 登録失敗時のテスト
  test "unsuccessful edit" do
    get edit_user_path(@user)

    patch user_path(@user),
    params: {
      user: {
        name:                  "",
        email:                 "user@invalid",
        password:              "foo",
        password_confirmation: "bar"
      }
    }

    # 登録失敗の場合はeditとレイアウトが一致していることをテストする
    assert_template('users/edit')

    # エラーメッセージが存在することをテストする
    assert_select('div#error_explanation')
    assert_select('div.alert', 'The form contains 4 errors.')
  end
end
