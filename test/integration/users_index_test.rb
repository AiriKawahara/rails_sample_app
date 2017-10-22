require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  # 管理者ユーザーがログインした時のテスト
  test "index as admin including pagination and delete links" do
    # 1. ログイン
    log_in_as(@admin)

    # 2. indexページにアクセス
    get users_path

    # 3. 最初のページにユーザーがいることを確認
    assert_template('users/index')
    User.paginate(page: 1).each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)
      unless user == @admin
        # 自分以外のユーザーにはdeleteボタンがあることを確認
        assert_select('a[href=?]', user_path(user), text: 'delete')
      end
    end
    
    # 4. ページネーションのリンクがあることを確認
    assert_select('div.pagination', count:1)

    # ユーザー数が1減少していることを確認
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 管理者でないユーザーがログインした時のテスト
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select('a', text: 'delete', count: 0)
  end
end
