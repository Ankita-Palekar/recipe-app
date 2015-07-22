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

ActiveRecord::Schema.define(:version => 20150721130342) do

  create_table "ingredients", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                  :null => false
    t.string   "meal_class",            :null => false
    t.string   "std_measurement"
    t.integer  "std_quantity"
    t.integer  "calories_per_quantity"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "ingredients_recipes", :force => true do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
    t.integer "quantity"
  end

  add_index "ingredients_recipes", ["recipe_id", "ingredient_id"], :name => "index_ingredients_recipes_on_recipe_id_and_ingredient_id", :unique => true

  create_table "ratings", :force => true do |t|
    t.integer "recipe_id"
    t.integer "user_id"
    t.integer "rating"
  end

  create_table "recipes", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",              :null => false
    t.text     "image_links"
    t.text     "description",       :null => false
    t.string   "meal_class",        :null => false
    t.integer  "total_calories"
    t.integer  "aggregate_ratings"
    t.integer  "serves"
    t.boolean  "approved"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "password_digest",                    :null => false
    t.boolean  "is_admin",        :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
