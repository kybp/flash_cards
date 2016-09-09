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

ActiveRecord::Schema.define(version: 20160909015425) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flash_cards", force: :cascade do |t|
    t.string   "question",                                    null: false
    t.string   "answer",                                      null: false
    t.float    "easiness",             default: 2.5,          null: false
    t.integer  "repetitions",          default: 0,            null: false
    t.integer  "review_interval",      default: 1,            null: false
    t.integer  "last_review_interval"
    t.date     "next_review_date",     default: '2016-09-08', null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

end
