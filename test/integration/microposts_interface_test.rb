require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    # 1. ログイン
    log_in_as(@user)
    get root_path
    # 2. マイクロポストのページ分割の確認
    assert_select 'div.pagination'
    # 3. 無効なマイクロポストを投稿
    assert_no_difference 'Micropost.count' do
      post microposts_path,
           params: { micropost: { content: "" }}
    end
    assert_select 'div#error_explanation'
    # 4. 有効なマイクロポストを投稿
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path,
           params: { micropost: { content: content }}
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 5. マイクロポストの削除
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 6. 他のユーザーのマイクロポストには[delete]リンクが表示されないことを確認
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  # サイドバーにあるマイクロポストの合計投稿数をテスト
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count}", response.body
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end
end
