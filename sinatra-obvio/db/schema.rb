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

ActiveRecord::Schema[7.2].define(version: 2025_05_25_145119) do
  create_table "accounts", force: :cascade do |t|
    t.integer "balance"
    t.string "cvu"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "contact_list_accounts", force: :cascade do |t|
    t.integer "contact_list_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contact_list_accounts_on_account_id"
    t.index ["contact_list_id", "account_id"], name: "index_contact_list_accounts_on_contact_list_id_and_account_id", unique: true
    t.index ["contact_list_id"], name: "index_contact_list_accounts_on_contact_list_id"
  end

  create_table "contact_lists", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contact_lists_on_account_id"
  end

  create_table "monthly_summaries", force: :cascade do |t|
    t.integer "initial_balance", null: false
    t.integer "final_balance", null: false
    t.text "note"
    t.string "balance_status"
    t.integer "transaction_count"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_monthly_summaries_on_account_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer "transfer_id"
    t.date "date"
    t.time "time"
    t.integer "amount"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transfer_id"], name: "index_receipts_on_transfer_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "transaction_number"
    t.integer "date"
    t.integer "time"
    t.integer "amount"
    t.string "description"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_account_id", null: false
    t.integer "target_account_id", null: false
    t.index ["source_account_id"], name: "index_transactions_on_source_account_id"
    t.index ["target_account_id"], name: "index_transactions_on_target_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "dni"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "password_digest"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "contact_list_accounts", "accounts"
  add_foreign_key "contact_list_accounts", "contact_lists"
  add_foreign_key "contact_lists", "accounts"
  add_foreign_key "monthly_summaries", "accounts"
  add_foreign_key "receipts", "transfers"
  add_foreign_key "transactions", "accounts", column: "source_account_id"
  add_foreign_key "transactions", "accounts", column: "target_account_id"
end
