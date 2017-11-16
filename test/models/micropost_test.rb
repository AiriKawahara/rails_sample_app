require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  # 1. fixtureのサンプルユーザーと紐づけた新しいマイクロポストを作成
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
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
end
