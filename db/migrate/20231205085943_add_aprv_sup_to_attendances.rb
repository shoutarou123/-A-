class AddAprvSupToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :aprv_sup, :string
  end
end

# ok