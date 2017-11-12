require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # 1. 「forgot　password」フォームで無効なメールアドレスを送信
    post password_resets_path,
         params: { password_reset: { email: "" }}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # 2. 「forgot　password」フォームで有効なメールアドレスを送信
    post password_resets_path,
         params: { password_reset: { email: @user.email }}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 配信されたメッセージがきっかり1つかどうか確認
    # deliveriesは変数なのでsetupメソッドでこれを初期化しておかないと
    # 並行して行われる他のテストでメールが配信されたときにエラーが発生する
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # 3. 2の場合パスワード再設定用トークンが作成され再設定用メールが送信される
    # assignsメソッドを使って対応するアクション内のインスタンス変数にアクセス
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # 有効化されていないユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # メールアドレスが有効でトークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # フォーム画面に隠しフィールドが存在するか
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # 4. メールのリンクを開いて無効な情報を送信
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
    params: {
      email: user.email,
      user: {
        password: "foobaz",
        password_confirmation: "barquux"
      }
    }
    assert_select "div#error_explanation"
    # パスワードが空
    patch password_reset_path(user.reset_token),
    params: {
      email: user.email,
      user: {
        password: "",
        password_confirmation: ""
      }
    }
    assert_select "div#error_explanation"
    # 5. メールのリンクを開いて有効な情報を送信
    patch password_reset_path(user.reset_token),
    params: {
      email: user.email,
      user: {
        password: "foobaz",
        password_confirmation: "foobaz"
      }
    }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
    # リセットダイジェストがnilになっていることを確認する
    assert_nil user.reload.reset_digest
  end

  # パスワード再設定の期限切れのテスト
  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email }}
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
    params: {
      email: @user.email,
      user: {
        password: "foobar",
        password_confirmation: "foobar"
      }
    }
    assert_response :redirect
    follow_redirect!
    # response.bodyはそのページのHTML本文をすべて返すメソッド
    assert_match "expired", response.body
  end
end
