module AttendancesHelper

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    hours_worked = (finish - start) / 3600.0 # 秒数を時間に変換
    format("%.2f", hours_worked)
  end

  def format_ended_at(day)
    day.ended_at.strftime('%H:%M')  # ended_atを "20:00" のようなフォーマットに変換
  end

  def calculate_overtime_hours(formatted_ended_at, designated_work_end_time, approved)
    # フォーマットされた終了予定時間を時間と分に分割
    ended_at_hours, ended_at_minutes = formatted_ended_at.split(":").map(&:to_i)
  
    # 指定勤務終了時間を時間と分に分割
    designated_work_end_hours, designated_work_end_minutes = designated_work_end_time.strftime('%H:%M').split(":").map(&:to_i)
  
    # 終了予定時間から指定勤務終了時間を引いて、秒数で取得
    overtime_seconds = (ended_at_hours * 3600 + ended_at_minutes * 60) - (designated_work_end_hours * 3600 + designated_work_end_minutes * 60)
    # :approved が '1' の場合、overtime_seconds に 24 時間分の秒数を足す
    if approved == true
      overtime_seconds += 24 * 3600
    end
    # 秒数を時間に変換して小数点第2位までの表示にフォーマット
    overtime_hours = (overtime_seconds / 3600.0).round(2)
    format("%.2f", overtime_hours)
  end
end

# ok