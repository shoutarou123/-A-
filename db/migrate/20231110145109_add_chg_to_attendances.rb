class AddChgToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :chg_next_day, :boolean
    add_column :attendances, :chg_confirmed, :string
    add_column :attendances, :chg_status, :string
    add_column :attendances, :b4_started_at, :datetime
    add_column :attendances, :b4_finished_at, :datetime
  end
end

# ok