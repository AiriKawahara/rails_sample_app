ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper

  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  # テスト内でユーザーがログインできるようにするためのヘルパーメソッド
  def log_in_as(user)
    # 毎回postメソッドとsessionハッシュを使ってログインするという無駄な繰り返しを避ける
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # テストユーザーとしてログインする
  def log_in_as(user, password: 'password', remember_me: '1')
    #　統合テストではsessionを直接取り扱うことができないのでSessionsリソースにpostを送信
    post login_path,
    params: {
      session: {
        email: user.email,
        password: password,
        remember_me: remember_me
      }
    }
  end
end
