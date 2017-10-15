require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    # fixtureのユーザーにアクセス
    @user = users(:michael)
    # sessions_helperのrememberメソッドで記憶する
    remember(@user)
  end

  # current_userが渡されたユーザーと同じであることを確認する
  test "current_user returns right user when session is nil" do
    # assert_equalは期待する値, 実際の値の順序で記載する
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # 記憶ダイジェストが間違っている時にcurrent_userメソッドがnilを返すか確認する
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
