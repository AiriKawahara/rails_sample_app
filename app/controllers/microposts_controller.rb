class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    # 新しいマイクロポストをbuildするためにUser/Mcropost関連付けを使っている
    # 登録する内容はおそらくviewのシンボルで判断している
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

    def micropost_params
      # Strong Parameters(DBへ追加したり更新するパラメータを制限する仕組み)
      # を使ってマイクロポストのcontent属性だけがWeb経由で変更可能にしている
      params.require(:micropost).permit(:content)
    end
end
