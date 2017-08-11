require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  # Homeページのテスト
  test "should get home" do
  	# アサーションと呼ばれる手法でテストを行う
  	# GETリクエストをhomeアクションに対して送信せよ
    get static_pages_home_url
    # そうすれば、リクエストに対するレスポンスは成功になるはず
    assert_response :success
    # <title>タグ内に「Home | Ruby on Rails Tutorial Sample App」という文字列があるかどうか
    assert_select "title", "Home | Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
  	get static_pages_about_url
  	assert_response :success
  	assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

end
