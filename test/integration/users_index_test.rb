require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    # 1. ログイン
    log_in_as(@user)

    # 2. indexページにアクセス
    get users_path

    # 3. 最初のページにユーザーがいることを確認
    assert_template('users/index')
    User.paginate(page: 1).each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)
    end
    
    # 4. ページネーションのリンクがあることを確認
    assert_select('div.pagination', count:1)
  end
end
