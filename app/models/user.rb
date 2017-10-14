class User < ApplicationRecord
  # migrationでオブジェクトのもつ属性を定義することとほぼ同義
  attr_accessor :remember_token
  # before_saveというコールバックを使い、オブジェクトが保存される際にemail属性を小文字に変換
  # Userモデルでは右辺のselfを省略することができる(左辺は省略することができない)
  # before_save { self.email = email.downcase }
  # 末尾に「!」を付け加えることによりemail属性を直接変更できるようになる
  before_save { email.downcase! }
  validates(
    :name,
    presence: true,
    length: { maximum: 50 }
  )
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(
    :email,
    presence: true,
    length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    # メールアドレスの大文字小文字を無視した一意性の検証
    uniqueness: { case_sensitive: false }
  )
  has_secure_password
  #has_secure_passwordの存在性のバリデーションは空文字を許容してしまうため以下のコードを追加
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # 記憶トークンの生成
    # selfを使用しないとremember_tokenというローカル変数が作成されてしまう
    self.remember_token = User.new_token
    # 記憶ダイジェストの更新
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンが記憶ダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # 以下のような比較も可能
    # BCrypt::Password.new(password_digest) == unencrypted_password
    # または
    # BCrypt::Password.new(remember_digest) == remember_token
    # remember_digestはself.remember_digestと同義
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
