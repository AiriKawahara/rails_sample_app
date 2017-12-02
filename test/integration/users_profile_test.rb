require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  # Applicationヘルパーを読み込むことでfull_titleヘルパーが利用できる
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    # ページタイトル
    assert_select 'title', full_title(@user.name)
    # ユーザ名
    assert_select 'h1', text: @user.name
    # Gravatar
    # h1タグの内側にあるgravatarクラス付きのimgタグがあるかどうか
    assert_select 'h1>img.gravatar'
    # マイクロポストの投稿数
    # response.bodyはそのページのHTML本文をすべて返すメソッド(bodyタグだけではない)
    # そのページのどこかしらにマイクロポストの投稿数が存在すればマッチする
    assert_match @user.microposts.count.to_s, response.body
    # will_paginateが一度のみ表示されていること
    assert_select 'div.pagination', count: 1
    # 分割されたマイクロポスト
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
    # プロフィールページにフォロー数フォロワー数が表示されているかテストする
    assert_match @user.active_relationships.count.to_s, response.body
    assert_match @user.passive_relationships.count.to_s, response.body
  end

  test "count relationships in home page" do
    log_in_as(@user)
    get root_path
    assert_match @user.active_relationships.count.to_s, response.body
    assert_match @user.passive_relationships.count.to_s, response.body
  end
end
