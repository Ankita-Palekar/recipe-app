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

# REVIEW -- how does one use a pre-existing ingredient?
ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "veg", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"soya", :meal_class=>"veg", :std_measurement=>"l", :std_quantity=>1, :calories_per_quantity=>250, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]

recipe = Recipe.new(:name => "papaya casew", :description => "grind papaya",:serves => 4, :aggregate_ratings => 4, :creator_id => 2)
recipe.create_recipe(:ingredients_list => ingredients_list)



