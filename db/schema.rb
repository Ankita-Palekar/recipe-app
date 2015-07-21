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

ActiveRecord::Schema.define(:version => 20150721053235) do

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
  end

  create_table "ingredients", :force => true do |t|
    t.string "name"
  end

  create_table "ingredients_recipes", :force => true do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
  end

  add_index "ingredients_recipes", ["recipe_id", "ingredient_id"], :name => "index_ingredients_recipes_on_recipe_id_and_ingredient_id", :unique => true

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["recipe_id"], :name => "index_ratings_on_recipie_id"
  add_index "ratings", ["user_id", "recipe_id"], :name => "index_ratings_on_user_id_and_recipe_id", :unique => true
  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "recipes", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",       :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "method"
    t.integer  "category_id"
  end

  add_index "recipes", ["user_id"], :name => "index_recipies_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",            :limit => nil
    t.string   "email",           :limit => nil,                  :null => false
    t.string   "password_digest", :limit => nil,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin",                          :default => "f"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
