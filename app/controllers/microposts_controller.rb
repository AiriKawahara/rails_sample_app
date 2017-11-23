class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    # 新しいマイクロポストをbuildするためにUser/Mcropost関連付けを使っている
    # 登録する内容はおそらくviewのシンボルで判断している
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.microposts.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # request.referrerメソッドは1つ前のURLを返す
    # DELETEリクエストが発行されたページに戻すことができる
    redirect_to request.referrer || root_url
    # 下のコードでもうまくいく
    # redirect_back(fallback_location: root_url)
  end

  private

    def micropost_params
      # Strong Parameters(DBへ追加したり更新するパラメータを制限する仕組み)
      # を使ってマイクロポストのcontent属性だけがWeb経由で変更可能にしている
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      # 関連付けを使ってマイクロポストを見つけることによって
      # 他のユーザーのマイクロポストを削除しようとすると自動的に失敗するようになる
      # 他のユーザーのマイクロポストを削除しようとした場合は@micropostがnilになる
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
