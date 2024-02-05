module UsersHelper
  
  # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    hours_worked = (time.hour * 60 + time.min) / 60.0
    format("%.2f", hours_worked)
  end
end

# ok