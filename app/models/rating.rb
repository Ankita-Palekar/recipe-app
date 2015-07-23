class Rating < ActiveRecord::Base
	belongs_to :user
	belongs_to :recipe
  attr_accessible :user_id, :recipe_id, :rating

  validates :rating, :presence => true, :numericality => true

end
