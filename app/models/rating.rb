class Rating < ActiveRecord::Base
	belongs_to :user, :foreign_key => 'rater_id'
	belongs_to :recipe, :include => :user
  attr_accessible :rater_id, :recipe_id, :ratings
  validates :ratings, :presence => true, :numericality => true, :inclusion => {:in =>0..5, :message => "ratings should be between 0-5"}
  validates :rater_id, presence:true
  validates :recipe_id, presence:true
  validates :rater_id, :uniqueness => {:scope => :recipe_id, :message => "you have already rated this recipe"}
   
end
