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

ActiveRecord::Schema.define(version: 20161006205032) do

  create_table "general_infos", force: :cascade do |t|
    t.text     "data",       limit: 1000000
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "money_burst_id"
    t.text     "data",           limit: 1000000
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["money_burst_id"], name: "index_logs_on_money_burst_id"
  end

  create_table "money_bursts", force: :cascade do |t|
    t.float    "init_amount"
    t.float    "cur_amount"
    t.string   "cur_currency"
    t.text     "data"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "state",                  default: "idle"
    t.string   "type",                   default: "TradingBurst"
    t.float    "remaining_after_buying", default: 0.0
    t.index ["state"], name: "index_money_bursts_on_state"
    t.index ["type"], name: "index_money_bursts_on_type"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "money_burst_id"
    t.string   "trans_type"
    t.float    "amount"
    t.float    "price"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.float    "final_obtained_amount"
    t.index ["money_burst_id"], name: "index_transactions_on_money_burst_id"
  end

end
