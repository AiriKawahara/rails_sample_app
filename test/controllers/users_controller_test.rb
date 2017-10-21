require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:michael) 
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  # indexアクションのリダイレクトをテストする
  test "should redirect index when not logged in" do
    # ログインしていない場合はログイン画面に強制的に遷移させる
    get users_path
    assert_redirected_to login_url
  end

  # ログインユーザーとは別のユーザーの編集ページには遷移できないことをテストする
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ログインユーザーとは別のユーザーの情報を更新することはできないことをテストする
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user),
    params: {
      user: {
        name: @user.name,
        email: @user.email
      }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
