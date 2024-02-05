class AddColumnsToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :aprv_status, :string
    add_column :attendances, :aprv_confirmed, :string
    add_column :attendances, :aprv_day, :date
  end
end

# ok