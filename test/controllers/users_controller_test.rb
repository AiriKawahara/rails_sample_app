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

  # admin属性の変更が禁止されていることをテストする
  test "should not allow the admin attribute to be edited via the web" do
    # 管理者でないユーザーにログインする
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user),
    params: {
      user: {
        password:              @other_user.password,
        password_confirmation: @other_user.password,
        admin: true
      }
    }
    # admin属性が変更されていないことを確認する
    assert_not @other_user.reload.admin?
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

  # ログインしていないユーザーがdeleteアクションにアクセスしようとすると
  # ログイン画面にリダイレクトされることをテストする
  test "should redirect destroy when not logged in" do
    # ユーザー数が変化しないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # ログイン済みのユーザーが管理者でない場合にdeleteアクションにアクセスしようとすると
  # ホーム画面にリダイレクトされることをテストする
  test " should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    
    assert_not @other_user.admin?

    # ユーザー数が変化しないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
