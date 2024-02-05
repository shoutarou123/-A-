class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_chg_req, :update_chg_req, :edit_overtime_req,
                                  :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_monthly_aprv, :update_monthly_req]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month, :edit_chg_req, :update_chg_req,
                                        :edit_overtime_req, :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_monthly_aprv,:update_monthly_req]
  before_action :superior_users, only: [:edit_one_month, :edit_chg_req, :edit_overtime_req, :edit_overtime_aprv, :edit_monthly_aprv]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :edit_chg_req, :update_chg_req, 
                                               :edit_overtime_req, :update_overtime_req, :edit_overtime_aprv, :update_overtime_aprv, :edit_monthly_aprv, :update_monthly_req]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month  #勤怠編集画面
    @superior = User.where(superior: true).where.not(id: @current_user.id)
  end
  
  def update_one_month
    flag = 0
    attendances_params.each do |id, item|
      unless item["started_at(4i)"].blank? || item["started_at(5i)"].blank? || item["finished_at(4i)"].blank? || item["finished_at(5i)"].blank?
        attendance = Attendance.find(id)
        if item[:chg_next_day].present? && item[:chg_confirmed].present?
          unless attendance.chg_status == "申請中"
            flag += 1
             # 初回の変更のみ保存
            if attendance.b4_started_at.blank? && attendance.b4_finished_at.blank?
              attendance.b4_started_at = attendance.started_at
              attendance.b4_finished_at = attendance.finished_at
            end
            attendance.chg_status = "申請中"
            attendance.update!(item)
          end
        end
      end
    end
    if flag > 0
      flash[:success] = "勤怠変更申請を送信しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  end

  def edit_chg_req  #上長への勤怠編集申請
    @attendances = Attendance.where(chg_confirmed: @user.name, chg_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end

  def update_chg_req
    flag = 0 
    chg_req_params.each do |id, item|
      if item[:chg_chk] == "1"
        unless item[:chg_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          if item[:chg_status] == "なし"
            attendance.started_at = attendance.b4_started_at
            attendance.finished_at = attendance.b4_finished_at
            attendance.note = nil
          elsif item[:chg_status] == "否認"
            attendance.started_at = attendance.b4_started_at
            attendance.finished_at = attendance.b4_finished_at
            attendance.note = nil
          end
          attendance.aprv_day = Date.current
          attendance.aprv_sup = attendance.chg_confirmed
          attendance.chg_confirmed = nil
          attendance.update(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "勤怠変更申請を更新しました。"
    else
      flash[:danger] = "勤怠変更申請の更新に失敗しました。"
    end
    redirect_to user_url(date: params[:date])
  end
  
  def edit_overtime_req  #残業申請
    @attendance = @user.attendances.find_by(worked_on: params[:date]) 
    @superior = User.where(superior: true).where.not(id: @current_user.id)
  end

  def update_overtime_req
    overtime_req_params.each do |id, item|
      attendance = Attendance.find(id)
      if item["ended_at(4i)"].blank? || item["ended_at(5i)"].blank? || item[:confirmed_request].blank? 
        flag = 1 if item[:approved] == '1'
      else
        flag = 1
      end
      if flag == 1
        attendance.overwork_chk = '0'
        attendance.overwork_status = "申請中"
        overtime_instructor = item["overtime_instructor"]
        attendance.update(item.merge(overtime_instructor: overtime_instructor))
        flash[:success] = "残業申請情報を送信しました。"
      else
        flash[:danger] = "未入力な項目があった為、申請をキャンセルしました。"
      end
    end
    redirect_to user_url
  end

  def edit_overtime_aprv   #上長への残業申請
    @attendances = Attendance.where(confirmed_request: @user.name, overwork_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end

  def update_overtime_aprv
    flag = 0
    overtime_aprv_params.each do |id, item|
      if item[:overwork_chk] == '1'
        unless item[:overwork_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          if item[:overwork_status] == "なし"
            attendance.ended_at = nil
            attendance.task_description = nil
          elsif
            item[:overwork_status] == "否認"
            attendance.ended_at = nil
            attendance.task_description = nil
          end
          attendance.update(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "残業申請を更新しました。"
    else
      flash[:danger] = "残業申請の更新に失敗しました。"
    end
    redirect_to user_url(date: params[:date])
  end

  def update_monthly_req  #一ヶ月分の勤怠申請
    flag = 0
    monthly_req_params.each do |id, item|
      if item[:aprv_confirmed].present?
        flag += 1
        attendance = Attendance.find(id)
        attendance.aprv_status = "申請中"
        attendance.update(item)
      end
    end 
    if flag > 0
      flash[:success] = "1ヶ月分の勤怠申請を送信しました。"
    else
      flash[:danger] = "1ヶ月分の勤怠申請に失敗しました。。"
    end
    redirect_to user_url(date: params[:date])
  end

  def edit_monthly_aprv  #上長への一ヶ月分の勤怠申請
    @attendances = Attendance.where(aprv_confirmed: @user.name, aprv_status: "申請中")
    @users = User.where(id: @attendances.select(:user_id))
  end
  
  def update_monthly_aprv
    flag = 0
    monthly_aprv_params.each do |id, item|
      if item[:aprv_chk] == "1"
        unless [:aprv_status] == "申請中"
          flag += 1
          attendance = Attendance.find(id)
          if item[:aprv_status] == "なし"
            attendance.aprv_status = nil
            attendance.aprv_confirmed = nil
          end
          attendance.update(item)
        end
      end
    end
    if flag > 0
      flash[:success] = "1ヶ月分の勤怠申請を更新しました。"
    else
      flash[:danger] = "1ヶ月分の勤怠申請の更新に失敗しました。"
    end
    redirect_to user_url
  end
    
  private
  
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :chg_next_day, :note, :chg_confirmed])[:attendances]
  end

  def chg_req_params
    params.require(:user).permit(attendances: [:chg_status, :chg_chk])[:attendances]
  end
  
  def overtime_req_params
    params.require(:user).permit(attendances: [:ended_at, :approved, :task_description, :confirmed_request])[:attendances]
  end

  def overtime_aprv_params
    params.require(:user).permit(attendances: [:overwork_status, :overwork_chk])[:attendances]
  end

  def monthly_req_params
    params.require(:user).permit(attendances: :aprv_confirmed)[:attendances]
  end

  def monthly_aprv_params
    params.require(:user).permit(attendances: [:aprv_chk, :aprv_status])[:attendances]
  end

# 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end  
  end 
end
  
#   ok