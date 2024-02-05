class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def set_users
    @users = User.all
  end
  
  def superior_users
    @superior = User.where.not(role: ['上長A', '上長B'])
  end

  def is_superior?
    if current_user
      current_user.superior == true
    else
      false
    end
  end
    
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  def current_user?(user)
    user == current_user
  end
  
# アクセスしたユーザーが現在ログインしているユーザーか確認します。
def correct_user
  @user = User.find(params[:id])
  # current_user が admin かどうかを確認
  if current_user.admin?
    redirect_to root_url
  else
    # admin でない場合、ユーザーが正しいかどうかを確認
    redirect_to root_url unless @user == current_user
  end
end
    
# システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
 # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
  
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end

# ok