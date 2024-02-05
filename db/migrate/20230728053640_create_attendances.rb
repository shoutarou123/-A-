class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :ended_at
      t.string :note
      t.string :task_description
      t.references :user, foreign_key: true
      t.boolean :approved, default: false
      

      t.timestamps
    end
  end
end

# ok