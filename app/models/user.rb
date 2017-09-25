class User < ApplicationRecord
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
end
