class Micropost < ApplicationRecord
  belongs_to :user
  # default_scopeメソッドを使ってデータベースから要素を取得した時の
  # デフォルトの順序を指定する(->はラムダ式：Procやlambdaと呼ばれるオブジェクトを作成する文法)
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
