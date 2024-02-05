class AddOvertimeEndTimeToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :overtime_end_time, :datetime
  end
end

# ok