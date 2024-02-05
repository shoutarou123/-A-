class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      
      if user.admin?
        flash[:success] = "管理者としてログインしました。"
        redirect_to root_path # 管理者はルートパスにリダイレクト
      else
        flash[:success] = "ログインに成功しました。"
        redirect_to user_path(user) # 一般ユーザーは詳細ページにリダイレクト
      end
    else
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end
  
    
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end

# ok