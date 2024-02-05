class AddOvertimeReqToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :overtime_req, :date
  end
end

# ok