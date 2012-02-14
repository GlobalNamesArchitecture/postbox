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

ActiveRecord::Schema.define(:version => 20120214023440) do

  create_table "contacts", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "names", :force => true do |t|
    t.string   "name_string", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "tree_id"
    t.integer  "name_id"
    t.string   "local_id"
    t.string   "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
  end

  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["tree_id"], :name => "index_nodes_on_tree_id"

  create_table "trees", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upload_id"
    t.integer  "status"
  end

  create_table "uploads", :force => true do |t|
    t.string   "email"
    t.string   "dwc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
