class StaticPagesController < ApplicationController
  def home
    # ビューに渡すための変数
    if logged_in?
      @micropost = current_user.microposts.build
      # フィードを使うために、現在のユーザーのページ分割されたフィードに
      # @feed_itemsインスタンス変数を追加する
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
