require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(
      follower_id: users(:michael).id,
      followed_id: users(:archer).id
    )
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    # 1. ユーザーをまだフォローしていないことを確認
    assert_not michael.following?(archer)
    # 2. ユーザーをフォロー
    michael.follow(archer)
    # 3. フォロー中になったことを確認
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    # 4. ユーザーをフォロー解除
    michael.unfollow(archer)
    # 5. フォロー解除したことを確認
    assert_not michael.following?(archer)
  end
end
