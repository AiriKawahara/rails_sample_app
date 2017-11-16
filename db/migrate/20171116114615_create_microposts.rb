class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      # references型を利用すると自動的にインデックスと
      # 外部キー参照付きのuser_idカラムが追加され
      # UserとMicropostを関連付けする下準備をしてくれる
      t.references :user, foreign_key: true

      t.timestamps
    end
    # 下のようにuser_idとcreated_atカラムにインデックスを付与することで
    # user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなる
    # user_idとcreated_atを1つの配列に含めることで複合キーインデックスが作成される
    add_index :microposts, [:user_id, :created_at]
  end
end
