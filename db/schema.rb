# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_12_05_085943) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "ended_at"
    t.string "note"
    t.string "task_description"
    t.integer "user_id"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "overtime_approval_status"
    t.string "overtime_instructor"
    t.date "overtime_req"
    t.boolean "overwork_chk"
    t.boolean "chg_chk"
    t.boolean "aprv_chk"
    t.datetime "overtime_end_time"
    t.string "aprv_status"
    t.string "aprv_confirmed"
    t.date "aprv_day"
    t.string "overwork_status"
    t.boolean "chg_next_day"
    t.string "chg_confirmed"
    t.string "chg_status"
    t.datetime "b4_started_at"
    t.datetime "b4_finished_at"
    t.string "confirmed_request"
    t.string "aprv_sup"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "base_points", force: :cascade do |t|
    t.string "base_number"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.string "employee_number"
    t.string "uid"
    t.string "role"
    t.boolean "admin", default: false
    t.boolean "superior", default: false
    t.datetime "start_time"
    t.datetime "basic_time", default: "2023-12-11 23:00:00"
    t.datetime "work_time", default: "2023-12-11 23:00:00"
    t.datetime "designated_work_start_time", default: "2023-12-12 01:00:00"
    t.datetime "designated_work_end_time", default: "2023-12-12 10:00:00"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "attendances", "users"
end

# ok