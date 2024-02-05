class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :affiliation
      t.string :employee_number
      t.string :uid
      t.string :role
      t.boolean :admin, default: false
      t.boolean :superior, default: false
      t.datetime :start_time
      t.datetime :basic_time, default: Time.current.change(hour: 8, min: 0, sec: 0)
      t.datetime :work_time, default: Time.current.change(hour: 8, min: 0, sec: 0)
      t.datetime :designated_work_start_time, default: Time.current.change(hour: 10, min: 0, sec: 0)
      t.datetime :designated_work_end_time, default: Time.current.change(hour: 19, min: 0, sec: 0)


      t.timestamps
    end
  end
end

# ok