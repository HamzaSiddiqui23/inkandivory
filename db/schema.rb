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

ActiveRecord::Schema.define(version: 2021_05_01_134049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "client_invoice_tasks", force: :cascade do |t|
    t.integer "client_invoice_id"
    t.integer "client_task_id"
  end

  create_table "client_invoices", force: :cascade do |t|
    t.date "invoice_created_date"
    t.string "status"
    t.string "client_id"
    t.integer "total_amount"
    t.integer "user_id"
    t.string "payment_type", default: "Submitted Word Count"
    t.integer "advance", default: 0
  end

  create_table "client_tasks", force: :cascade do |t|
    t.integer "client_id"
    t.string "task_title"
    t.integer "required_word_count"
    t.float "pay_rate"
    t.integer "writer_id"
    t.datetime "due_date_time"
    t.string "details"
    t.datetime "delivered_date"
    t.integer "submitted_word_count"
    t.string "submission"
    t.binary "submission_file"
    t.string "instructions"
    t.binary "instructions_file"
    t.datetime "task_accepted_date_stamp"
    t.datetime "task_submitted_date_stamp"
    t.datetime "task_revision_date_stamp"
    t.datetime "approved_rejected_date_stamp"
    t.integer "revision_number", default: 0
    t.string "status"
    t.string "client_payment_status"
    t.string "writer_payment_status"
    t.string "manager_payment_status"
    t.integer "client_payment_due"
    t.integer "writer_payment_due"
    t.integer "manager_payment_due"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "team_id"
    t.datetime "revision_due_date"
    t.datetime "revision_submission_date"
    t.string "payment_type", default: "Submitted Word Count"
    t.integer "advance", default: 0
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "source"
    t.string "status"
    t.string "client_representative"
    t.string "payment_method"
    t.string "frequency_of_payment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "minimum_due_amount"
  end

  create_table "internal_invoice_tasks", force: :cascade do |t|
    t.integer "internal_invoice_id"
    t.integer "client_task_id"
  end

  create_table "internal_invoices", force: :cascade do |t|
    t.date "invoice_created_date"
    t.string "status"
    t.integer "manager_total"
    t.integer "writer_total"
    t.integer "client_total"
    t.integer "user_id"
    t.integer "bonus"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_name"
    t.integer "manager_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "identification"
    t.string "phone"
    t.string "role"
    t.integer "manager_id"
    t.integer "team_id"
    t.date "birthday"
    t.string "bank_name"
    t.string "account_number"
    t.string "mailing_address"
    t.string "user_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "joining_date"
    t.string "status"
    t.string "resume"
    t.binary "resume_file"
    t.string "slack_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

end
