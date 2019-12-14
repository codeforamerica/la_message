# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_13_235743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "phone_number"
    t.boolean "opted_in"
    t.date "renewal_date"
    t.text "first_name"
    t.text "last_name"
    t.text "carrier_type"
    t.text "enrollment_documents", default: [], array: true
    t.text "response"
    t.text "list"
    t.text "individual_id"
    t.boolean "lameds_opt_in"
    t.integer "segment"
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.text "to_phone_number"
    t.text "from_phone_number"
    t.text "body"
    t.text "message_type"
    t.boolean "outbound"
    t.text "twilio_id"
    t.text "status"
    t.integer "error_code"
    t.text "error_message"
    t.index ["contact_id"], name: "index_messages_on_contact_id"
    t.index ["twilio_id"], name: "index_messages_on_twilio_id", unique: true
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string "phone_number"
    t.string "wic_id"
    t.string "snap_id"
    t.string "tanf_id"
    t.string "medicaid_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "sms_deliverable", default: 0
    t.boolean "opt_in", default: false
    t.boolean "wic_opt_in", default: false
    t.boolean "medicaid_opt_in", default: false
    t.boolean "snap_opt_in", default: false
    t.boolean "tanf_opt_in", default: false
  end

end
