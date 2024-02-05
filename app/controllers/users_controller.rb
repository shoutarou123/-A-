class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :attendance_log]
  before_action :set_users, only: [:index, :show, :attendance_list]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :attendance_log]
  before_action :superior_users, only: [:show]
  before_action :correct_user, only: [:show, :edit]
  before_action :admin_user, only: [:index, :attendance_list]
  before_action :set_one_month, only: [:show]
  
  
  def index
  end
  
  def import
    if params[:file].present? && File.extname(params[:file].original_filename) == ".csv"
      flash[:success] = 'CSVファイルを読み込みました'
      User.import(params[:file])
      redirect_to users_url
    else
      flash[:danger] = 'CSVファイルを選択してください'
      redirect_to users_url
    end
  end

  def show
    @current_user = current_user
    @superior = User.where(superior: true).where.not(id: @current_user.id)
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)   # 該当日の残業申請取得
    @worked_sum = @attendances.where.not(started_at: nil).count  # 出勤日数
    @monthly_count = Attendance.where(aprv_confirmed: @user.name, aprv_status: "申請中").count #上長への一ヶ月分の勤怠申請
    @month_count = Attendance.where(chg_confirmed: @user.name, chg_status: "申請中").count  # 勤怠変更のお知らせ件数
    @aprv_count = Attendance.where(confirmed_request: @user.name, overwork_status: "申請中").count  # 残業申請のお知らせ件数
    @overtime_instructor = @attendances.first.overtime_instructor if @attendances.first  

    respond_to do |format|
      format.html
      format.csv { send_data User.generate_csv(@attendances), filename: "#{@user.name}_#{Time.zone.now.strftime('%Y年%m月分')}.csv" }
    end    
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url 
    else
      flash[:danger] = "ユーザー情報を更新できませんでした。"
      redirect_to users_url   
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def attendance_list
  end

  def attendance_log
    @attendances = @user.attendances.where(chg_status: "承認").order(:worked_on)
  
    if params["select_year(1i)"].present? && params["select_month(2i)"].present?
      @first_day = (params["select_year(1i)"] + "-" + params["select_month(2i)"] + "-01").to_date
      @attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month, chg_status: "承認").order(:worked_on)
    end
  end
  
    
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :affiliation, :password, 
                                 :password_confirmation, :employee_number, 
                                 :uid, :designated_work_start_time, 
                                 :designated_work_end_time)
  end
end

# ok