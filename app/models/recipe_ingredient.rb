class RecipeIngredient < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :recipe
  attr_accessible :recipe_id, :ingredient_id, :quantity
end



