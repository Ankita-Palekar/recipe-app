# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#   

 
# users_list = [{email: "ankita@vacationlabs.com", password: "ankita"},
# {email: "453ankitapalekar@gmail.com", password: "anki-cool"},
# {email: "pradosh@vacationlabs.com", password: "pradosh"},
# {email: "lakshadeep@vacationlabs.com", password: "lakshadeep"}
# ]

# users_list.each do |u|
# 	User.create(u)
# end

ingredients_list = [{:name=>"milk", :meal_class=>"veg", :std_measurement=>"l", :std_quantity=>1, :calories_per_quantity=>250, :quantity => 2}, {:name=>"casew", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100}]


recipe = Recipe.new(:name => "modak", :description => "boil milk, chop dry fruits, knead dough",:serves => 4, :aggregate_ratings => 4, :user_id => 2, :meal_class => Recipe.get_recipe_meal_class(:ingredients_list => ingredients_list))
# recipe.name = "vanilla icecream"
# recipe.description = 
# recipe.serves = 4
# recipe.aggregate_ratings = 4
# recipe.user_id = 1

recipe.create_recipe(:ingredients_list => ingredients_list)



