class AddConfirmedRequestToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :confirmed_request, :string
  end
end

# ok