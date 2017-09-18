require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
  	@base_title = "Ruby on Rails Tutorial Sample App"
  end

  # Homeページのテスト
  test "should get home" do
  	# アサーションと呼ばれる手法でテストを行う
  	# GETリクエストをhomeアクションに対して送信せよ
    get root_path
    # そうすれば、リクエストに対するレスポンスは成功になるはず
    assert_response :success
    # <title>タグ内に「Home | Ruby on Rails Tutorial Sample App」という文字列があるかどうか
    assert_select "title", "#{@base_title}"
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
  	get about_path
  	assert_response :success
  	assert_select "title", "About | #{@base_title}"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end

end
