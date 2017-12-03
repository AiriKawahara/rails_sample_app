require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user  = users(:michael)
    @other = users(:archer)
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

  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should follow a user with Ajax" do
    # Ajax版では xhr :true オプションを使うようにする
    # 上記のオプションを設定するとAjaxでリクエストを発生するように変わる
    # controllerのrespond_toではJavaScriptに対応した行が実行されるようになる
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
end
