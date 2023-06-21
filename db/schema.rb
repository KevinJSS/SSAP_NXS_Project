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

ActiveRecord::Schema[7.0].define(version: 2023_06_20_172641) do
  create_table "activities", force: :cascade do |t|
    t.integer "worked_hours", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.boolean "nested_phases", default: false
    t.index ["project_id"], name: "index_activities_on_project_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.string "fullname", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_emergency_contacts_on_user_id"
  end

  create_table "minutes", force: :cascade do |t|
    t.string "meeting_title", null: false
    t.date "meeting_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.text "meeting_objectives"
    t.text "discussed_topics"
    t.text "pending_topics"
    t.text "agreements"
    t.text "meeting_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id", null: false
    t.index ["project_id"], name: "index_minutes_on_project_id"
  end

  create_table "minutes_users", force: :cascade do |t|
    t.integer "minute_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["minute_id"], name: "index_minutes_users_on_minute_id"
    t.index ["user_id"], name: "index_minutes_users_on_user_id"
  end

  create_table "phases", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phases_activities", force: :cascade do |t|
    t.integer "phase_id", null: false
    t.integer "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_phases_activities_on_activity_id"
    t.index ["phase_id"], name: "index_phases_activities_on_phase_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "scheduled_deadline"
    t.text "location"
    t.integer "stage", null: false
    t.integer "stage_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_card", null: false
    t.string "fullname", null: false
    t.string "phone", null: false
    t.string "address", null: false
    t.integer "role", null: false
    t.string "job_position", null: false
    t.string "account_number"
    t.integer "id_card_type", null: false
    t.integer "marital_status", null: false
    t.date "birth_date", null: false
    t.string "province", null: false
    t.string "canton", null: false
    t.string "district", null: false
    t.integer "education", null: false
    t.string "nationality", null: false
    t.integer "gender", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "projects"
  add_foreign_key "activities", "users"
  add_foreign_key "emergency_contacts", "users"
  add_foreign_key "minutes", "projects"
  add_foreign_key "minutes_users", "minutes"
  add_foreign_key "minutes_users", "users"
  add_foreign_key "phases_activities", "activities"
  add_foreign_key "phases_activities", "phases"
  add_foreign_key "projects", "users"
end
