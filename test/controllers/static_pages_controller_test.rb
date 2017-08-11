require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
  	@base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "should get root" do
    get root_url
    assert_response :success
  end

  # Homeページのテスト
  test "should get home" do
  	# アサーションと呼ばれる手法でテストを行う
  	# GETリクエストをhomeアクションに対して送信せよ
    get static_pages_home_url
    # そうすれば、リクエストに対するレスポンスは成功になるはず
    assert_response :success
    # <title>タグ内に「Home | Ruby on Rails Tutorial Sample App」という文字列があるかどうか
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
  	get static_pages_about_url
  	assert_response :success
  	assert_select "title", "About | #{@base_title}"
  end

end
