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

ActiveRecord::Schema.define(:version => 20110102055634) do

  create_table "domain_server_connections", :force => true do |t|
    t.integer  "domain_id"
    t.integer  "server_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.string   "fqdn",                            :null => false
    t.integer  "refresh"
    t.integer  "retry"
    t.integer  "expire"
    t.integer  "default_ttl"
    t.integer  "version",      :default => 1
    t.integer  "builds_today", :default => 0
    t.boolean  "active",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "zone_file"
  end

  create_table "records", :force => true do |t|
    t.integer  "domain_id",     :null => false
    t.string   "name",          :null => false
    t.string   "resource_type"
    t.integer  "priority"
    t.integer  "weight"
    t.integer  "port"
    t.string   "target"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "server_messages", :force => true do |t|
    t.integer  "server_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", :force => true do |t|
    t.string   "ip"
    t.string   "identifier"
    t.string   "key"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

end
