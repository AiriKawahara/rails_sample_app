require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    # 以下のコードがtrueになるとeach文が実行されなくなるため
    # falseになりeach文が実行されることを確認
    assert_not @user.following.empty?
    # 正しい数が表示されているか
    assert_match @user.following.count.to_s, response.body
    # URLが正しいか
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    # 以下のコードがtrueになるとeach文が実行されなくなるため
    # falseになりeach文が実行されることを確認
    assert_not @user.followers.empty?
    # 正しい数が表示されているか
    assert_match @user.followers.count.to_s, response.body
    # URLが正しいか
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
