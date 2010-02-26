# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100226011355) do

  create_table "house_staffs", :force => true do |t|
    t.integer  "bu_code"
    t.integer  "staff_id"
    t.string   "position_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sort_order"
    t.string   "position_type"
  end

  create_table "houses", :force => true do |t|
    t.integer  "bu_code"
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "fax"
    t.text     "overview"
    t.string   "ratio"
    t.text     "trainings_needed"
    t.text     "medication_times"
    t.string   "relief_pay"
    t.text     "waivers"
    t.string   "keys"
    t.text     "schedule_info"
    t.text     "behavior_plans"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_info"
  end

  create_table "imports", :force => true do |t|
    t.integer  "processed",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
  end

  create_table "staff_infos", :force => true do |t|
    t.integer  "staff_id"
    t.text     "experience_prefs"
    t.text     "skills_limits"
    t.text     "schedule_availability"
    t.text     "contact_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", :force => true do |t|
    t.integer  "staff_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "gender"
    t.date     "doh"
    t.string   "cell_number"
    t.string   "home_number"
    t.boolean  "agency_staff"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
  end

  create_table "user_houses", :force => true do |t|
    t.integer  "bu_code"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

end
