require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Example User",
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    )
  end

  # 有効なユーザーどうかのテスト
  test "should be valid" do
    assert @user.valid?
  end

  # name属性の存在性のテスト
  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  # email属性の存在性のテスト
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  # name属性の最大文字数のテスト
  test "name should be not too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  # email属性の最大文字数のテスト
  test "email should be not too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # email属性のフォーマットのテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # email属性のフォーマットのテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

<<<<<<< HEAD
=======
  # email属性の一意性のテスト
>>>>>>> 6modeling_users
  test "email addresses should be unique" do
    # dupは同じ属性を持つデータを複製するためのメソッド
    duplicate_user = @user.dup
    # 通常メールアドレスでは大文字小文字が区別されないため大文字を区別せずにテストを行う
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

<<<<<<< HEAD
=======
  # email属性の小文字化に対するテスト
>>>>>>> 6modeling_users
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
<<<<<<< HEAD
=======

  # パスワードの存在性のテスト
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  # パスワードの最小文字数のテスト
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
>>>>>>> 6modeling_users
end
