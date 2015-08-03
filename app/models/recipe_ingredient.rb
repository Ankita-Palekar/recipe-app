class RecipeIngredient < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :recipe
  attr_accessible :recipe_id, :ingredient_id, :quantity
  validates :recipe_id, :uniqueness => {:scope => :ingredient_id, :message => "recipe ingredient entry already exists in db"}
end



