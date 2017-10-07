require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path

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

    # 送信失敗の場合はnewアクションが再描画されていることをテストする
    assert_template('users/new')

    # エラーメッセージをテストする
    assert_select('div#error_explanation')
    assert_select('div.alert')

    # POSTが送信されているURLが正しいかをテストする
    assert_select('form[action="/signup"]')
  end
end
