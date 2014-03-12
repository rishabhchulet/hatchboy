# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140312134905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "user_id"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["invitation_token"], name: "index_accounts_on_invitation_token", unique: true, using: :btree
  add_index "accounts", ["invited_by_id"], name: "index_accounts_on_invited_by_id", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "created_by_id"
    t.integer  "contact_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["contact_person_id"], name: "index_companies_on_contact_person_id", using: :btree
  add_index "companies", ["created_by_id"], name: "index_companies_on_created_by_id", using: :btree

  create_table "docu_signs", force: true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.string   "envelope_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document"
  end

  add_index "docu_signs", ["company_id"], name: "index_docu_signs_on_company_id", using: :btree
  add_index "docu_signs", ["user_id"], name: "index_docu_signs_on_user_id", using: :btree

  create_table "documents", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "doc_file"
    t.string   "doc_type"
    t.integer  "doc_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["owner_id", "owner_type"], name: "index_documents_on_owner_id_and_owner_type", using: :btree

  create_table "payment_recipients", force: true do |t|
    t.integer "payment_id"
    t.integer "user_id"
    t.float   "amount"
  end

  create_table "payment_transactions", force: true do |t|
    t.integer  "payment_id"
    t.string   "payment_system"
    t.string   "status"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "company_id"
    t.integer  "created_by_id"
    t.string   "status"
    t.string   "description"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paypal_configurations", force: true do |t|
    t.integer "company_id"
    t.string  "login"
    t.string  "password"
    t.string  "signature"
  end

  add_index "paypal_configurations", ["company_id"], name: "index_paypal_configurations_on_company_id", using: :btree

  create_table "post_receivers", force: true do |t|
    t.integer  "post_id"
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_receivers", ["post_id"], name: "index_post_receivers_on_post_id", using: :btree
  add_index "post_receivers", ["receiver_id", "receiver_type"], name: "index_post_receivers_on_receiver_id_and_receiver_type", using: :btree

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "sources", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "type"
    t.string   "url"
    t.string   "consumer_key"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.text     "private_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consumer_secret"
  end

  create_table "sources_users", force: true do |t|
    t.integer  "source_id"
    t.integer  "user_id"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.text     "description"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams_sources", force: true do |t|
    t.integer  "team_id"
    t.integer  "source_id"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams_users", force: true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "contact_email"
    t.string   "role"
    t.string   "status"
    t.string   "avatar"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_logs", force: true do |t|
    t.integer  "team_id"
    t.integer  "source_id"
    t.integer  "user_id"
    t.string   "uid_in_source"
    t.string   "issue"
    t.date     "on_date"
    t.integer  "time"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
