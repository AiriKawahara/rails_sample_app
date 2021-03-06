class Micropost < ApplicationRecord
  belongs_to :user
  # default_scopeメソッドを使ってデータベースから要素を取得した時の
  # デフォルトの順序を指定する(->はラムダ式：Procやlambdaと呼ばれるオブジェクトを作成する文法)
  default_scope -> { order(created_at: :desc) }
  # アップローダーを追加
  # CarrierWaveに画像と関連付けたモデルを伝えるためには
  # mount_uploaderというメソッドを使う
  # このメソッドは引数に属性名のシンボルと生成されたアップローダーのクラス名をとる
  # picture_uploader.rbというファイルでPictureUploaderクラスが定義されている
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  # 独自のバリデーションを追加
  # validateメソッドでは引数にシンボルを取り
  # そのシンボル名に対応したメソッドを呼び出す
  validate  :picture_size

  private

    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
