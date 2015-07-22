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

ingredients_list = [{:name=>"chana", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>100, :calories_per_quantity=>500 }]


recipe = Recipe.new 
recipe.name = "Chole"
recipe.description = "Chole Masala"
recipe.serves = 4
recipe.aggregate_ratings = 4
recipe.create_recipe(:ingredients_list => ingredients_list)



