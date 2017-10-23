class User < ApplicationRecord
  # migrationでオブジェクトのもつ属性を定義することとほぼ同義
  attr_accessor :remember_token, :activation_token
  # before_saveというコールバックを使い、オブジェクトが保存される際にemail属性を小文字に変換
  # Userモデルでは右辺のselfを省略することができる(左辺は省略することができない)
  # before_save { self.email = email.downcase }
  # 末尾に「!」を付け加えることによりemail属性を直接変更できるようになる
  # before_save { email.downcase! }
  # メソッド参照に変更
  before_save :downcase_email

  # メソッド参照
  # ユーザーを作成する前に有効化トークンと有効化ダイジェストを作成する
  before_create :create_activation_digest

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
  # has_secure_passwordではオブジェクト生成時に存在性を検証する
  has_secure_password
  # has_secure_passwordの存在性のバリデーションは空文字を許容してしまうため以下のコードを追加
  # 「allow_nil: true」はパスワードのバリデーションに対して空だった時の例外処理
  # 「allow_nil: true」を追加することでパスワードが空のままでも更新できるようになる
  # 「allow_nil: true」を追加すると存在性のバリデーションとhas_secure_passwordによるバリデーション
  # それぞれが実行され2つの同じエラー文が表示されるというバグも解消できる
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
    # 記憶ダイジェストがnilの場合はfalseを返す
    return false if remember_digest.nil?
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

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end
    
    # 有効化トークンと有効化ダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
