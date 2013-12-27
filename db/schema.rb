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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "access_tokens", :force => true do |t|
    t.string   "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "answers", :force => true do |t|
    t.string   "uid"
    t.string   "content"
    t.integer  "message_id"
    t.integer  "user_id"
    t.boolean  "result",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "cdks", :force => true do |t|
    t.string   "uid"
    t.string   "content"
    t.datetime "send_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cheers", :force => true do |t|
    t.string   "weixin_token"
    t.string   "weibo_token"
    t.string   "weixin_uid"
    t.string   "weibo_uid"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "image"
    t.string   "generated_image"
    t.string   "name"
    t.string   "content"
    t.string   "desc"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "label"
    t.string   "token"
    t.string   "uid"
  end

  add_index "messages", ["token"], :name => "index_messages_on_token"

  create_table "questions", :force => true do |t|
    t.string   "image"
    t.string   "music"
    t.string   "options"
    t.string   "answer"
    t.string   "media_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.boolean  "over_today",            :default => false
    t.integer  "right_answers_counter"
    t.string   "uid"
    t.string   "right_question_ids",    :default => ""
    t.integer  "last_question_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

end
