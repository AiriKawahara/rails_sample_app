require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  # 1. fixtureのサンプルユーザーと紐づけた新しいマイクロポストを作成
  def setup
    @user = users(:michael)
    # 下コードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    # 下のコードは慣習的に正しい
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end
  
  # 2. 作成したマイクロポストが有効かどうかをチェックするテスト
  test "should be valid" do
    assert @micropost.valid?
  end
  
  # 3. user_idの存在性のバリデーションに対するテスト
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    # データベース上の最初のマイクロポストがfixture内のマイクロポスト
    # most_recentと同じであるか確認
    assert_equal microposts(:most_recent), Micropost.first
  end
end
