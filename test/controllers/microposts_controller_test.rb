require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @micropost = microposts(:orange)
  end

  # 下の2つのテストでは未ログインの場合に正しいリクエストを発行した場合
  # マイクロポスト数が変化せず、ログインページにリダイレクトされるかどうかを確認する
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path,
           params: { micropost: { content: "Lorem ipsum" }}
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  # 自分以外のユーザーのマイクロポストを削除しようとすると
  # 適切にリダイレクトされることをテストで確認
  test "should redirect destroy for wrong  micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end
end
