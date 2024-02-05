class AddOverworkChkToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :overwork_chk, :boolean
    add_column :attendances, :chg_chk, :boolean
    add_column :attendances, :aprv_chk, :boolean
  end
end

# ok