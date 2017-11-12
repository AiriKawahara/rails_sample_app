class User < ApplicationRecord
  # migrationでオブジェクトのもつ属性を定義することとほぼ同義
  # ただしハッシュ化していないトークンはセキュリティのためDBには格納しない
  attr_accessor :remember_token, :activation_token, :reset_token
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
  # アカウント有効化のダイジェストと渡されたトークンが一致するかチェック
  def authenticated?(attribute, token)
    # メタプログラミング：プログラムでプログラムを作成する
    # sendメソッド：渡されたオブジェクトにメッセージを送ることによって
    # 呼び出すメソッドを動的に決めることができる
    # attributeとして:attributeが渡された場合は
    # userオブジェクトにactivation_digestメソッドを渡している
    # selfは省略可能
    digest = self.send("#{attribute}_digest")
    # 記憶ダイジェストがnilの場合はfalseを返す
    return false if digest.nil?
    # 以下のような比較も可能
    # BCrypt::Password.new(password_digest) == unencrypted_password
    # または
    # BCrypt::Password.new(remember_digest) == remember_token
    # remember_digestはself.remember_digestと同義
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # Userモデルにはuserという変数がないためuser.という記法は使っていない
    # user.update…だとエラーになるのでself.update…と記述してもよいが
    # モデル内ではselfは必須ではないのでここでは省略
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    # 上のコードだとDBに2回問い合わせているので1回で済むようにする
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
    # update_attribute(:reset_digest,  )
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      # self.email = email.downcase
      email.downcase!
    end
    
    # 有効化トークンと有効化ダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
