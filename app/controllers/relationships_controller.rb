class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # Ajaxの場合はインスタンス変数を使う
    # またビューで変数を使うためuserが@userに変わった
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # Ajaxリクエストに応答できるようにする
    # リクエストの種類によって応答を場合分けする時はrespond_toメソッドを使う
    # respond_toメソッドはブロック内のいずれかの1行が実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
